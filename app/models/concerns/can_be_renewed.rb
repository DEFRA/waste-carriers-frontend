module CanBeRenewed
  extend ActiveSupport::Concern

  def can_renew?(log_reason = false, error_id = :can_renew)
    if lower?
      add_validation_error(:registration_is_lower_tier, error_id) if log_reason
      return false
    end

    unless %w[ACTIVE EXPIRED].include?(metaData.first.status)
      add_validation_error(:registration_not_active, error_id) if log_reason
      return false
    end

    expiry_date_service = ExpiryDateService.new(expires_on)
    if expired?
      unless expiry_date_service.in_expiry_grace_window?
        add_validation_error(:registration_expired, error_id) if log_reason
        return false
      end
    end

    unless expiry_date_service.in_renewal_window?
      add_validation_error(:registration_not_in_renewal_window, error_id) if log_reason
      return false
    end

    true
  end

  def expired?
    return false if lower?

    return true if metaData&.first&.status == "EXPIRED"

    return true if ExpiryDateService.new(expires_on).expired?

    false
  end

  def renewals_url
    "#{Rails.configuration.renewals_service_url}#{regIdentifier}"
  end

  def back_office_renewals_url
    "#{Rails.configuration.back_office_renewals_url}#{regIdentifier}"
  end

  private

  def add_validation_error(key, error_id)
    case key
    when :registration_is_lower_tier
      translation = I18n.t(
        "errors.messages.registration_is_lower_tier",
        helpline: Rails.configuration.registrations_service_phone.to_s
      )
    when :registration_not_active
      translation = I18n.t(
        "errors.messages.registration_not_active",
        helpline: Rails.configuration.registrations_service_phone.to_s
      )
    when :registration_expired
      translation = I18n.t("errors.messages.registration_expired")
    when :registration_not_in_renewal_window
      renew_from = ExpiryDateService.new(expires_on).date_can_renew_from
      translation = I18n.t(
        "errors.messages.registration_not_in_renewal_window",
        date: renew_from.to_formatted_s(:day_month_year)
      )
    end

    errors.add(error_id, translation) if translation
  end

end

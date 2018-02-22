module CanBeRenewed
  extend ActiveSupport::Concern

  def can_renew?(log_reason = false, error_id = :can_renew)
    if lower?
      add_validation_error(:registration_is_lower_tier, error_id) if log_reason
      return false
    end

    unless metaData.first.status == 'ACTIVE'
      add_validation_error(:registration_not_active, error_id) if log_reason
      return false
    end

    if expired?
      add_validation_error(:registration_expired, error_id) if log_reason
      return false
    end

    service = ExpiryDateService.new(expires_on)
    unless service.in_renewal_window?
      add_validation_error(:registration_not_in_renewal_window, error_id) if log_reason
      return false
    end

    true
  end

  def expired?
    return false if lower?
    return true if metaData.first.status == 'EXPIRED'

    service = ExpiryDateService.new(expires_on)

    return true if service.expired?

    false
  end

  def renewals_url
    "#{Rails.configuration.renewals_service_url}#{regIdentifier}"
  end

  private

  def add_validation_error(key, error_id)
    case key
    when :registration_is_lower_tier
      translation = I18n.t(
        'errors.messages.registration_is_lower_tier',
        helpline: Rails.configuration.registrations_service_phone.to_s
      )
    when :registration_not_active
      translation = I18n.t(
        'errors.messages.registration_not_active',
        helpline: Rails.configuration.registrations_service_phone.to_s
      )
    when :registration_expired
      translation = I18n.t('errors.messages.registration_expired')
    when :registration_not_in_renewal_window
      renew_from = ExpiryDateService.new(expires_on).date_can_renew_from
      translation = I18n.t(
        'errors.messages.registration_not_in_renewal_window',
        date: ExpiryDateService.date_as_day_ordinal_date_month_and_year(renew_from)
      )
    end

    errors.add(error_id, translation) if translation
  end

end

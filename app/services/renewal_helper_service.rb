class RenewalHelperService
  attr_reader :registration

  def initialize(registration, log_reason = false, error_id = :can_renew)
    @registration = registration
    @log_reason = log_reason
    @error_id = error_id
  end

  def can_renew?
    return false unless tier_is_renewable?
    return false unless status_is_renewable?

    if @registration.expired?
      return false unless in_expired_grace_window?
    else
      return false unless in_renewal_window?
    end

    true
  end

  private

  def tier_is_renewable?
    return true unless @registration.lower?

    add_validation_error(:registration_is_lower_tier) if @log_reason
    false
  end

  def status_is_renewable?
    return true if %w[ACTIVE EXPIRED].include?(@registration&.metaData&.first&.status)

    add_validation_error(:registration_not_active) if @log_reason
    false
  end

  def in_expired_grace_window?
    return true if ExpiryDateService.new(@registration.expires_on).in_expiry_grace_window?

    add_validation_error(:registration_expired) if @log_reason
    false
  end

  def in_renewal_window?
    return true if ExpiryDateService.new(@registration.expires_on).in_renewal_window?

    add_validation_error(:registration_not_in_renewal_window) if @log_reason
    false
  end

  def add_validation_error(key)
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
      renew_from = ExpiryDateService.new(@registration.expires_on).date_can_renew_from
      translation = I18n.t(
        "errors.messages.registration_not_in_renewal_window",
        date: renew_from.to_formatted_s(:day_month_year)
      )
    end

    @registration.errors.add(@error_id, translation) if translation
  end

end

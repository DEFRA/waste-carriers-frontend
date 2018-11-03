module CanBeRenewed
  extend ActiveSupport::Concern

  def can_renew?(log_reason = false, error_id = :can_renew)
    helper = RenewalHelperService.new(self, log_reason, error_id)
    helper.can_renew?
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
end

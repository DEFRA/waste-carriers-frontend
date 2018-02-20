module CanBeRenewed
  extend ActiveSupport::Concern

  def can_renew?
    return false if lower?
    return false unless metaData.first.status == 'ACTIVE'
    return false if expired?

    date_service = DateService.new(expires_on)
    return false unless date_service.in_renewal_window?

    true
  end

  def expired?
    return false if lower?
    return true if metaData.first.status == 'EXPIRED'

    date_service = DateService.new(expires_on)

    return true if date_service.expired?

    false
  end

  def renewals_url
    "#{Rails.configuration.renewals_service_url}#{regIdentifier}"
  end

end

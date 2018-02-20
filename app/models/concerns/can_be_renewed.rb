module CanBeRenewed
  extend ActiveSupport::Concern

  def expired?
    return false if lower?
    return true if metaData.first.status == 'EXPIRED'

    date_service = DateService.new(expires_on)
    return true if date_service.expired?

    false
  end

end

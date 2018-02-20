# Contains methods related to dealing with dates in the service, for example
# whether a date would be considered as expired.
class DateService
  def initialize(provided_date)
    @date = provided_date.to_date
  end

  # For more details about the renewal window check out
  # https://github.com/DEFRA/waste-carriers-renewals/wiki/Renewal-window
  def date_can_renew_from
    (@date - Rails.configuration.registration_renewal_window)
  end

  def expired?
    # Registrations are expired on the date recorded for their expiry date e.g.
    # an expiry date of Mar 25 2018 means the registration was active up till
    # 24:00 on Mar 24 2018.
    return false if @date > Date.today

    true
  end

end

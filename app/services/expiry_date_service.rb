# Contains methods related to dealing with dates in the service, for example
# whether a date would be considered as expired.
class ExpiryDateService
  attr_reader :expiry_date

  def initialize(expiry_date)
    return if default_source_date(expiry_date)

    return if date_from_utc_milliseconds(expiry_date)

    @expiry_date = expiry_date.to_date
  end

  # For more details about the renewal window check out
  # https://github.com/DEFRA/waste-carriers-renewals/wiki/Renewal-window
  def date_can_renew_from
    (@expiry_date - Rails.configuration.registration_renewal_window)
  end

  def expired?
    # Registrations are expired on the date recorded for their expiry date e.g.
    # an expiry date of Mar 25 2018 means the registration was active up till
    # 24:00 on Mar 24 2018.
    return false if @expiry_date > Date.today

    true
  end

  def in_renewal_window?
    # If the registration expires in more than x months from now, its outside
    # the renewal window
    return true if @expiry_date < Rails.configuration.registration_renewal_window.from_now

    false
  end

  private

  # Believe we have functionality that relies on setting dates to the epoch
  # where no existing date exists hence this bit of functionality
  def default_source_date(provided_date)
    return false unless provided_date.nil?

    @expiry_date = Date.new(1970,1,1)

    true
  end

  def date_from_utc_milliseconds(milliseconds)
    return false if milliseconds.is_a? Date
    return false if milliseconds.is_a? Time

    milliseconds = milliseconds.to_i if milliseconds.is_a? String

    @expiry_date = Time.at(milliseconds / 1000.0).to_date

    true
  end

end
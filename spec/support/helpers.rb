module Helpers
  # Because the Java services returns dates as UTC timestamps in milliseconds
  # when we want to set a date on a Registration in our tests we have to convert
  # it to a timestamp.
  # https://stackoverflow.com/a/20003818/6117745
  def date_to_utc_milliseconds(date)
    date.strftime('%Q').to_i
  end

  # These helper methods move the implementation of working out a date that is
  # within the grace window, and one that is outside it here away from the tests
  # that use them. What the tests are concerned with is what happens in these
  # contexts so to simplify them we added these 2 helpers.
  def date_inside_grace_window(expires_on)
    (expires_on + Rails.configuration.registration_grace_window) - 1.day
  end

  def date_outside_grace_window(expires_on)
    (expires_on + Rails.configuration.registration_grace_window)
  end
end

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
  #
  # Its important to note that a registration is expired on its expires_on date.
  # For example if the expires_on date is Oct 1, then the registration was
  # ACTIVE Sept 30, and EXPIRED Oct 1. If the grace window is 3 days, just
  # adding 3 days to that date would give the impression the grace window lasts
  # till Oct 4 (i.e. 1 + 3) when in fact we need to include the 1st as one of
  # our grace window days.
  def date_inside_grace_window(expires_on)
    (expires_on + Rails.configuration.registration_grace_window) - 1.day
  end

  def date_outside_grace_window(expires_on)
    (expires_on + Rails.configuration.registration_grace_window)
  end
end

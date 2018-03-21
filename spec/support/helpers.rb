module Helpers
  # Because the Java services returns dates as UTC timestamps in milliseconds
  # when we want to set a date on a Registration in our tests we have to convert
  # it to a timestamp.
  # https://stackoverflow.com/a/20003818/6117745
  def date_to_utc_milliseconds(date)
    date.strftime('%Q').to_i
  end
end

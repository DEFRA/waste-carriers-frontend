# frozen_string_literal: true

# There is a reason for the additional `Rails.env == "test"` condition!
# After many attempts trying to set whether last email cache is enabled or not
# in our unit tests we realised that the initializers are called before any kind
# of mocking/stubbing goes on in an RSpec test. So we would never be able to
# control whether the interceptor is registered or not when testing.
#
# So next we looked at ignoring the interceptor and using either RSpec filters
# or hooks to control the registering and unregistering of the interceptor.
# However we hit an issue there as well. Registering the interceptor was fine,
# but unregistering was only merged into ActionMailer in May 2018
# (https://github.com/rails/rails/pull/32207).
#
# So to ensure the tests were clean and the interceptor removed when they
# finished we were left with having to introduce a monkey patch. 😩
#
# This seemed overkill for what we wanted to achieve, hence this final solution
# which is to always register the interceptor if we are running in "test".
if Rails.configuration.use_last_email_cache || Rails.env == "test"
  ActionMailer::Base.register_interceptor(LastEmailCache)
end

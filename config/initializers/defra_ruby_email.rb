# frozen_string_literal: true

DefraRubyEmail.configure do |configuration|
  # Enable the last-email route mounted in this app if the environment is
  # configured
  configuration.enable = ENV["WCRS_USE_LAST_EMAIL_CACHE"] || false
end

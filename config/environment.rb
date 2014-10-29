# Load the rails application
require File.expand_path('../application', __FILE__)

ActionMailer::Base.smtp_settings = {
  :user_name => ENV["WCRS_FRONTEND_EMAIL_USERNAME"],
  :password => ENV["WCRS_FRONTEND_EMAIL_PASSWORD"],
  :domain => 'www.wastecarriers.service.gov.uk',
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

Money.default_currency = Money::Currency.new 'GBP'

# Logging: log timestamp with the log message
class Logger
  def format_message(level, time, progname, msg)
    "#{level} [#{time.to_s(:dbmsec)}] -- #{msg}\n"
#    "#{time.utc} #{level} -- #{msg}\n"
  end
end

# Initialize the rails application
Registrations::Application.initialize!



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

# Initialize the rails application
Registrations::Application.initialize!



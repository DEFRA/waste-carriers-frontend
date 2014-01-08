Registrations::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  # config.whiny_nils = true

  config.eager_load = false
  
  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Deprecated - Raise exception on mass assignment protection for Active Record models
  # config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # - Deprecated in Rails 4
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Sending e-mails is required for user management and registration e-mails
  config.action_mailer.default_url_options = { :host => ENV['WCRS_FRONTEND_PUBLIC_APP_DOMAIN'] || 'http://localhost:3000' }

  # Don't care if the mailer can't send (if set to false)
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :user_name => ENV["WCRS_FRONTEND_EMAIL_USERNAME"],
    :password => ENV["WCRS_FRONTEND_EMAIL_PASSWORD"],
    :domain => ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"],
    :address => ENV["WCRS_FRONTEND_EMAIL_HOST"],
    :port => ENV["WCRS_FRONTEND_EMAIL_PORT"],
    :authentication => :plain,
    :enable_starttls_auto => true
  }

  # Overriding 'Done' URL for development
  #config.waste_exemplar_end_url = "https://www.gov.uk/done/waste-carrier-or-broker-registration"
  config.waste_exemplar_end_url = "/gds-end"

end

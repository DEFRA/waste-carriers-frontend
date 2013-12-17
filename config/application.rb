require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Registrations
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.

    #Deprecated in Rails 4
    #config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      "#{html_tag}".html_safe
    }

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    #Our services URL. This application is the REST-based client of that service API.
    #As described in the comments above, this setting can be redefined in config/environments/*.rb
    #Changing this value requires restart of the application
    config.waste_exemplar_services_url = ENV["WCRS_FRONTEND_WCRS_SERVICES_URL"] || "http://localhost:9090"
    config.waste_exemplar_addresses_url = ENV["WCRS_FRONTEND_WCRS_ADDRESSES_URL"] || "http://localhost:9190"

    #The application URL
    config.waste_exemplar_frontend_url = ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"] || "http://localhost:3000"

    #The application URL
    config.waste_exemplar_frontend_admin_url = ENV["WCRS_FRONTEND_ADMIN_APP_DOMAIN"] || "http://localhost:3000"

    #The subdomains used in links for password reset and other e-mails sent by the Devise authentication component.
    config.waste_exemplar_frontend_public_subdomain = ENV["WCRS_FRONTEND_PUBLIC_APP_SUBDOMAIN"] || "www.wastecarriersregistration.service"
    config.waste_exemplar_frontend_admin_subdomain = ENV["WCRS_FRONTEND_ADMIN_APP_SUBDOMAIN"] || "admin.wastecarriersregistration.service"

    #In Production we want to verify that requests to agency user and administration functionality
    #have been made via the 'internal' domain URL 'https://admin.wastecarriersregistration.service.gov.uk'
    #rather than via the public domain and URL 'https://www.wastecarriersregistration.service.gov.uk'
    config.require_admin_requests = Rails.env.production? || ENV["WCRS_FRONTEND_REQUIRE_ADMIN_REQUESTS"] || false
    
    # Add a URL to represent the GOV.UK page that the process goes to, after the registration happy path
    config.waste_exemplar_end_url = "https://www.gov.uk/done/waste-carrier-or-broker-registration"
    config.waste_exemplar_eaupper_url = "https://integrated-regulation.environment-agency.gov.uk/EAIntegratedRegulationInternet/?_flowId=carriersandbrokers-flow"
    config.waste_exemplar_eaPrivacyCookies_url = "http://www.environment-agency.gov.uk/help/35770.aspx"
    
    # Set configuration for error pages to manual, to enable more user friendly error pages
    config.exceptions_app = self.routes

    # Update this whenever the reported version number is supposed to have changed - particularly before any new releases. 
    # Note: This is the version of the frontend application. The version number of the services application may change separately.
    # Use semantic versioning (Major.Minor.Patch)
    config.application_version = '1.0.0'

    # The e-mail address shown on the Finish page and used in e-mails sent by the application
    config.registrations_service_email = 'registrations@wastecarriersregistration.service.gov.uk'
    
    # The phone number shown on the certificate and used in e-mails sent by the application
    config.registrations_service_phone = '03708 506506'

    #Business types available for registrations. 
    #Note: When adding or removing, please also adjust locale-specific values in localisation files.
    config.registration_business_types = %w[
      soleTrader 
      partnership 
      limitedCompany 
      charity
      collectionAuthority
      disposalAuthority
      regulationAuthority
      other]

    #Titles. Please also edit locale-specific values in localisation files.
    config.registration_titles = %w[mr mrs miss ms dr other]

    #Tracking using Google Analytics should be performed only in Production
    config.use_google_analytics = ENV['WCRS_FRONTEND_USE_GOOGLE_ANALYTICS'] || Rails.env.production?

    #Total (a.k.a. global) session timeout - total session duration
    config.app_session_total_timeout = 8.hours

    #Inactivity timeout - between requests - should be 20 minutes, except for agency users
    config.app_session_inactivity_timeout = 20.minutes

  end
end

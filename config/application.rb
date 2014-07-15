require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "csv"
# require "rails/test_unit/railtie"

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
    config.application_version = '1.2.0_alpha'

    # The e-mail address shown on the Finish page and used in e-mails sent by the application
    config.registrations_service_email = 'registrations@wastecarriersregistration.service.gov.uk'
    config.registrations_service_emailName = 'EA Waste Carrier Service'

    # The phone number shown on the certificate and used in e-mails sent by the application
    config.registrations_service_phone = '03708 506506'
    config.registrations_cy_service_phone = '03000 653000'

    #Tracking using Google Analytics; must be performed only in Production, but is optional in development
    #(and uses a different Google Tag Manager ID - see below)
    config.use_google_analytics = ENV['WCRS_FRONTEND_USE_GOOGLE_ANALYTICS'] || Rails.env.production?

    #The Google Tag Manager ID used with Google Analytics and the Google Tag Manager.
    #We use a different ID in production; this here is the development ID.
    config.google_tag_manager_id = 'GTM-W27LBD'

    #Total (a.k.a. global) session timeout - total session duration
    config.app_session_total_timeout = 8.hours

    #Inactivity timeout - between requests - should be 20 minutes, except for agency users
    config.app_session_inactivity_timeout = 20.minutes

    #Show the developer index page? - Do not show in production, but do show in development, or maybe sandbox
    #The developer index page contains links to external and internal entry points
    #If the developer index is not to be shown (as in production), then the application
    #will redirect the user to a suitable entry point, such as the 'Find out if I need to register' page
    config.show_developer_index_page = false

    #Use the letter opener gem if the environment variable is set. Don't use the letter opener in production!
    config.use_letter_opener = ENV["WCRS_FRONTEND_USE_LETTER_OPENER"] || false

    # Worldpay configuration: 
    # using the e-commerce (ECOM) channel configuration for external users (Waste Carriers),
    # using the integrated MOTO channel configuration for internal user (assisted digital)
    config.worldpay_ecom_merchantcode = ENV['WCRS_WORLDPAY_ECOM_MERCHANTCODE'] || 'MERCHANTCODE'
    config.worldpay_ecom_username = ENV['WCRS_WORLDPAY_ECOM_USERNAME'] || 'USERNAME'
    config.worldpay_ecom_password = ENV['WCRS_WORLDPAY_ECOM_PASSWORD'] || 'PASSWORD'
    config.worldpay_ecom_macsecret = ENV['WCRS_WORLDPAY_ECOM_MACSECRET'] || 'MACSECRET'

    config.worldpay_moto_merchantcode = ENV['WCRS_WORLDPAY_MOTO_MERCHANTCODE'] || 'MERCHANTCODE'
    config.worldpay_moto_username = ENV['WCRS_WORLDPAY_MOTO_USERNAME'] || 'USERNAME'
    config.worldpay_moto_password = ENV['WCRS_WORLDPAY_MOTO_PASSWORD'] || 'PASSWORD'
    config.worldpay_moto_macsecret = ENV['WCRS_WORLDPAY_MOTO_MACSECRET'] || 'MACSECRET'

    # Offline payment
    config.environment_agency_bank_account_name = 'Environment Agency'
    config.environment_agency_bank_name = 'Citibank'
    config.environment_agency_bank_address = 'Citigroup Centre, Canada Square, London, E14 5LB'
    config.bank_transfer_sort_code = '08-33-00'
    config.bank_transfer_account_number = '12800543'
    config.iban_number = 'GB23 CITI0833 0012 8005 43'
    config.swiftbic_number = 'CITI GB2LXXX'
    config.income_email_address = 'FSC.AR@environment-agency.gov.uk'
    config.income_fax_number = '01733 464892'
    config.income_postal_address = 'Environment Agency, Income Dept 311, PO Box 263, Peterborough, PE2 8YD'
  end
end

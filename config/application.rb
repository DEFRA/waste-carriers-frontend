require File.expand_path('../boot', __FILE__)

require 'active_model/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'csv'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(assets: %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Registrations
  class Application < Rails::Application
    # Helper which takes a URL from the specified environment variable, or uses
    # a default value if the environment variable isn't set, and ensures it is
    # prefixed with a protocol (such as 'http://').
    def self.get_url_from_environment_or_default(environment_variable_name, default_value)
      value = ENV[environment_variable_name]
      value = default_value if value.blank?
      value = format("http://#{value}") unless value =~ %r{://}
      value
    end

    # Settings in config/environments/* take precedence over those specified
    # here.  Application configuration should go into files in
    # config/initializers; all .rb files in that directory are automatically
    # loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Enable the asset pipeline
    config.assets.enabled = true

    config.action_view.field_error_proc = proc { |html_tag, _instance|
      "#{html_tag}".html_safe
    }

    # Our services URL. This application is the REST-based client of that
    # service API.  As described in the comments above, this setting can be
    # redefined in 'config/environments/*.rb'.
    # Changing this value requires restart of the application.
    config.waste_exemplar_services_url            = get_url_from_environment_or_default('WCRS_FRONTEND_WCRS_SERVICES_URL',       'http://localhost:9090')
    config.waste_exemplar_services_admin_url      = get_url_from_environment_or_default('WCRS_FRONTEND_WCRS_SERVICES_ADMIN_URL', 'http://localhost:9091')
    config.waste_exemplar_addresses_url           = get_url_from_environment_or_default('WCRS_FRONTEND_WCRS_ADDRESSES_URL',      'http://localhost:9190')
    config.waste_exemplar_elasticsearch_url       = get_url_from_environment_or_default('WCRS_ELASDB_URL_REST',                  'http://localhost:9200')

    # The application URL.
    config.waste_exemplar_frontend_url            = get_url_from_environment_or_default('WCRS_FRONTEND_PUBLIC_APP_DOMAIN',       'http://localhost:3000')

    # The application admin URL.
    config.waste_exemplar_frontend_admin_url      = get_url_from_environment_or_default('WCRS_FRONTEND_ADMIN_APP_DOMAIN',        'http://localhost:3000')

    # Settings relating to the Convictions Service.
    config.waste_exemplar_convictions_service_url = get_url_from_environment_or_default('WCRS_FRONTEND_CONVICTIONS_SERVICE_URL', 'http://localhost:9290')

    # The subdomains used in links for password reset and other e-mails sent by
    # the Devise authentication component.
    config.waste_exemplar_frontend_public_subdomain = ENV['WCRS_FRONTEND_PUBLIC_APP_SUBDOMAIN'] || 'localhost'
    config.waste_exemplar_frontend_admin_subdomain  = ENV['WCRS_FRONTEND_ADMIN_APP_SUBDOMAIN']  || 'localhost'

    # Settings relating to Companies House.
    config.waste_exemplar_companies_house_url = 'http://www.companieshouse.gov.uk/info'

    # In Production we want to verify that requests to agency user and
    # administration functionality have been made via the 'internal' subdomain
    # URL rather than via the public domain and URL.
    config.require_admin_requests = Rails.env.production? || ENV['WCRS_FRONTEND_REQUIRE_ADMIN_REQUESTS'] || false

    # Add a URL to represent the GOV.UK page that the process goes to, after the
    # registration happy path.
    config.waste_exemplar_end_url              = 'https://www.gov.uk/done/waste-carrier-or-broker-registration'
    config.waste_exemplar_eaupper_url          = 'https://integrated-regulation.environment-agency.gov.uk/EAIntegratedRegulationInternet/?_flowId=carriersandbrokers-flow'
    config.waste_exemplar_eaPrivacyCookies_url = 'http://www.environment-agency.gov.uk/help/35770.aspx'

    # Set configuration for error pages to manual, to enable more user friendly
    # error pages.
    config.exceptions_app = self.routes

    config.autoload_paths << Rails.root.join('lib')

    # Update this whenever the reported version number is supposed to have
    # changed - particularly before any new releases.  Note: this is the version
    # of the frontend application. The version number of the services
    # application may change separately.
    # Use semantic versioning (Major.Minor.Patch).
    config.application_version = '2.2.0-beta'

    # The e-mail address shown on the Finish page and used in e-mails sent by
    # the application.
    config.registrations_service_email = 'registrations@wastecarriersregistration.service.gov.uk'
    config.registrations_service_emailName = 'Waste Carriers Service'

    # The phone number shown on the certificate and used in e-mails sent by the
    # application.
    config.registrations_service_phone = '03708 506506'
    config.registrations_cy_service_phone = '03000 653000'

    # Attempt to pick up the Google Tag Manager ID from an environment variable.
    # If the variable is not set, we cannot use Google Analytics.
    config.google_tag_manager_id = ENV['WCRS_FRONTEND_GOOGLE_TAGMANAGER_ID']

    # Tracking using Google Analytics. As noted above, we can only do this if we
    # know the Google Tag Manager ID.  Additionally, whilst we want to do this
    # in production, it is optional elsewhere.
    config.use_google_analytics = false
    unless config.google_tag_manager_id.blank?
      config.use_google_analytics = (ENV['WCRS_FRONTEND_USE_GOOGLE_ANALYTICS'] == 'true') || Rails.env.production?
    end

    # Total (a.k.a. global) session timeout - total session duration.
    config.app_session_total_timeout = 8.hours

    # Inactivity timeout - between requests - should be 20 minutes, except for
    # agency users.
    config.app_session_inactivity_timeout = 20.minutes

    # Show the developer index page?  Do not show in production, but do show in
    # development, or maybe sandbox.  The developer index page contains links to
    # external and internal entry points.  If the developer index is not to be
    # shown (as in production), then the application will redirect the user to a
    # suitable entry point, such as the 'Find out if I need to register' page.
    config.show_developer_index_page = false

    # Use the letter opener gem if the environment variable is set. Don't use
    # the letter opener in production!
    config.use_letter_opener = ENV['WCRS_FRONTEND_USE_LETTER_OPENER'] || false

    # Worldpay configuration:
    # Waste Carriers use the e-commerce (ECOM) channel configuration;
    # Assisted Digital uses the integrated MOTO channel configuration.
    config.worldpay_ecom_merchantcode = ENV['WCRS_WORLDPAY_ECOM_MERCHANTCODE'] || 'MERCHANTCODE'
    config.worldpay_ecom_username = ENV['WCRS_WORLDPAY_ECOM_USERNAME'] || 'USERNAME'
    config.worldpay_ecom_password = ENV['WCRS_WORLDPAY_ECOM_PASSWORD'] || 'PASSWORD'
    config.worldpay_ecom_macsecret = ENV['WCRS_WORLDPAY_ECOM_MACSECRET'] || 'MACSECRET'

    config.worldpay_moto_merchantcode = ENV['WCRS_WORLDPAY_MOTO_MERCHANTCODE'] || 'MERCHANTCODE'
    config.worldpay_moto_username = ENV['WCRS_WORLDPAY_MOTO_USERNAME'] || 'USERNAME'
    config.worldpay_moto_password = ENV['WCRS_WORLDPAY_MOTO_PASSWORD'] || 'PASSWORD'
    config.worldpay_moto_macsecret = ENV['WCRS_WORLDPAY_MOTO_MACSECRET'] || 'MACSECRET'

    # Using the Worldpay TEST service in all environments by default.
    config.worldpay_uri = 'https://secure-test.worldpay.com/jsp/merchant/xml/paymentService.jsp'

    # Offline payment.
    config.environment_agency_bank_account_name = 'Environment Agency'
    config.environment_agency_bank_name = 'RBS/Natwest'
    config.environment_agency_bank_address = 'Royal Bank of Scotland plc, London Corporate Service Centre, CPB Services 2nd Floor, 280 Bishopsgate, London, EC2M 4RB'
    config.bank_transfer_sort_code = '60-70-80'
    config.bank_transfer_account_number = '10014411'
    config.iban_number = 'GB23 NWBK6070 8010 0144 11'
    config.swiftbic_number = 'NWBK GB2L'
    config.income_email_address = 'ea_fsc_ar@sscl.gse.gov.uk'
    config.income_fax_number = '01733 464892'
    config.income_postal_address = 'Environment Agency, SSCL Banking Team, PO Box 263, Peterborough, PE2 8YD'

    # Fees/charges: provide as a number expressed in pence (cents).
    # TODO: Have a more elaborate fee structure (and/or the fees in the
    # database?) which allows us to set new fees in advance so that this
    # configuration file does not need to be edited at new years eve late or
    # whenever new fees come into place.
    config.fee_registration = Monetize.parse('£154').cents
    config.fee_renewal = Monetize.parse('£105').cents
    config.fee_copycard = Monetize.parse('£5').cents
    config.fee_reg_type_change = Monetize.parse('£40').cents

    # Conviciton checks must be completed within limit.
    config.registrations_service_exceed_limit = '10'

    # Registration expiration (upper tier only; lower tier registrations are
    # indefinite).
    config.registration_expires_after = (ENV['WCRS_REGISTRATION_EXPIRES_AFTER'] || '3').to_i.years

    # Upper tier registrations can be renewed starting a given time period (e.g.
    # 6 months) before their expiration date.
    config.registration_renewal_window = (ENV['WCRS_REGISTRATION_RENEWAL_WINDOW'] || '6').to_i.months
  end
end

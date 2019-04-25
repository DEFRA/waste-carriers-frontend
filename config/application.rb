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
    # Settings in config/environments/* take precedence over those specified
    # here.  Application configuration should go into files in
    # config/initializers; all .rb files in that directory are automatically
    # loaded.

    def renewal_service_url(app_path)
      base_url = base_url(app_path)
      path = if ENV['WCRS_HOLD_RENEWALS']
        '/renew/'
      else
        "/#{app_path}/renew/"
      end
      "#{base_url}#{path}"
    end

    def base_url(app_path)
      if Rails.env.production?
        # In production the base url needs to match the external url, hence we
        # can just pull from our config.
        back_office = config.waste_exemplar_frontend_admin_url
        front_office = config.waste_exemplar_frontend_url
      else
        back_office = ENV['WCRS_BACKOFFICE_DOMAIN'] || 'http://localhost:8001'
        front_office = ENV['WCRS_RENEWALS_DOMAIN'] || 'http://localhost:3000'
      end

      return front_office if app_path == "fo"
      back_office
    end

    config.time_zone = "Europe/London"

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

    config.waste_exemplar_frontend_url = ENV['WCRS_FRONTEND_DOMAIN'] || 'http://localhost:3000'
    config.waste_exemplar_frontend_admin_url = ENV['WCRS_FRONTEND_ADMIN_DOMAIN'] || 'http://localhost:3000'

    config.waste_exemplar_services_url = ENV['WCRS_SERVICES_DOMAIN'] || 'http://localhost:8003'
    config.waste_exemplar_services_admin_url = ENV['WCRS_SERVICES_ADMIN_DOMAIN'] || 'http://localhost:8004'
    config.waste_exemplar_addresses_url = ENV['WCRS_OS_PLACES_DOMAIN'] || 'http://localhost:8005'

    config.renewals_service_url = renewal_service_url("fo")
    config.back_office_renewals_url = renewal_service_url("bo")

    config.front_office_url = base_url("fo")
    config.back_office_url = base_url("bo")

    # The subdomains used in links for password reset and other e-mails sent by
    # the Devise authentication component.
    config.subdomain = ENV['WCRS_FRONTEND_SUBDOMAIN'] || 'localhost:3000'
    config.admin_subdomain = ENV['WCRS_FRONTEND_ADMIN_SUBDOMAIN'] || 'localhost:3000'

    # Settings relating to Companies House.
    config.waste_exemplar_companies_house_api_url = ENV["WCRS_COMPANIES_HOUSE_URL"] || "https://api.companieshouse.gov.uk/company/"
    config.waste_exemplar_companies_house_api_key = ENV['WCRS_COMPANIES_HOUSE_API_KEY']
    config.waste_exemplar_companies_house_url = 'http://www.companieshouse.gov.uk/info'

    # (The value for this environment variable should be a comma-separated list of allowed
    # company statuses.  We convert this into a whitespace-free array of strings below)
    config.waste_exemplar_allowed_company_statuses =
      (ENV['WCRS_FRONTEND_ALLOWED_COMPANY_STATUSES'] || 'active, voluntary-arrangement').split(/\s*,\s*/)

    # In Production we want to verify that requests to agency user and
    # administration functionality have been made via the 'internal' subdomain
    # URL rather than via the public domain and URL.
    config.require_admin_requests = Rails.env.production? || false

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
    config.application_version = '2.3.2-beta'

    # The e-mail address shown on the Finish page and used in e-mails sent by
    # the application.
    # In our dev environments if we are not using mailcatcher and actually want
    # to send an email, we must use something other than
    # registrations@wastecarriersregistration.service.gov.uk. This is because
    # email recipients like Gmail will check the details of the email against
    # the production DMARC setup and will spot an inconsistency because we are
    # not using the production sendgrid credentials to send the email. In most
    # cases they will then block receipt of the email.
    # By using something else e.g. wcr-dev@example.com, as no DMARC is set it
    # will not fail the check so is unlikely to be blocked (but might be flagged
    # within the email client).
    config.registrations_service_email = ENV["WCRS_EMAIL_SERVICE_EMAIL"] || 'registrations@wastecarriersregistration.service.gov.uk'
    config.registrations_service_emailName = 'Waste Carriers Registration Service'

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
      config.use_google_analytics = (ENV['WCRS_USE_GOOGLE_ANALYTICS'] == 'true') || Rails.env.production?
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

    # Worldpay configuration:
    # Waste Carriers use the e-commerce (ECOM) channel configuration;
    # Assisted Digital uses the integrated MOTO channel configuration.
    config.worldpay_uri = ENV["WCRS_WORLDPAY_URL"] || "https://secure-test.worldpay.com/jsp/merchant/xml/paymentService.jsp"
    config.worldpay_ecom_merchantcode = ENV['WCRS_WORLDPAY_ECOM_MERCHANTCODE'] || 'MERCHANTCODE'
    config.worldpay_ecom_username = ENV['WCRS_WORLDPAY_ECOM_USERNAME'] || 'USERNAME'
    config.worldpay_ecom_password = ENV['WCRS_WORLDPAY_ECOM_PASSWORD'] || 'PASSWORD'
    config.worldpay_ecom_macsecret = ENV['WCRS_WORLDPAY_ECOM_MACSECRET'] || 'MACSECRET'

    config.worldpay_moto_merchantcode = ENV['WCRS_WORLDPAY_MOTO_MERCHANTCODE'] || 'MERCHANTCODE'
    config.worldpay_moto_username = ENV['WCRS_WORLDPAY_MOTO_USERNAME'] || 'USERNAME'
    config.worldpay_moto_password = ENV['WCRS_WORLDPAY_MOTO_PASSWORD'] || 'PASSWORD'
    config.worldpay_moto_macsecret = ENV['WCRS_WORLDPAY_MOTO_MACSECRET'] || 'MACSECRET'

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

    config.fee_registration = ENV["WCRS_REGISTRATION_CHARGE"].to_i
    config.fee_renewal = ENV["WCRS_RENEWAL_CHARGE"].to_i
    config.fee_copycard = ENV["WCRS_CARD_CHARGE"].to_i
    config.fee_reg_type_change = ENV["WCRS_TYPE_CHANGE_CHARGE"].to_i

    # Conviciton checks must be completed within limit.
    config.registrations_service_exceed_limit = '10'

    # Registration expiration (upper tier only; lower tier registrations are
    # indefinite).
    config.registration_expires_after = (ENV['WCRS_REGISTRATION_EXPIRES_AFTER'] || '3').to_i.years

    # Upper tier registrations can be renewed starting a given time period (e.g.
    # 6 months) before their expiration date.
    config.registration_renewal_window = (ENV['WCRS_REGISTRATION_RENEWAL_WINDOW'] || '3').to_i.months

    # Expired Upper tier registrations can still be renewed if the current date
    # is within a given 'grace window' after the registration expired. So if the
    # window is 3 days, the current date is October 12, and the reg. expired Oct
    # 10 then the reg. is within the window and can still be renewed.
    config.registration_grace_window = (ENV["WCRS_REGISTRATION_GRACE_WINDOW"] || "3").to_i.days

    config.email_test_address = ENV["WCRS_EMAIL_TEST_ADDRESS"] || "waste-carriers@example.com"

    config.assisted_digital_account_email = ENV["WCRS_ASSISTED_DIGITAL_EMAIL"]

    # Expose the data stored by the LastEmailCache. Only used in our acceptance
    # tests and should not be enabled in production.
    config.use_last_email_cache = ENV["WCRS_USE_LAST_EMAIL_CACHE"] || false
  end
end

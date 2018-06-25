Registrations::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = false

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false

  # Compress JavaScripts and CSS
  config.assets.css_compressor = :sass
  config.assets.js_compressor = :uglifier

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :warn

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Sending e-mails is required for user management and registration e-mails
  config.action_mailer.default_url_options = { :host => config.mailer_url, :protocol => 'https' }

  # Don't care if the mailer can't send (if set to false)
  config.action_mailer.raise_delivery_errors = false

  # Ensures images included in emails that originate from our assest folder and pipepline
  # can still be viewed in emails. See
  # http://stackoverflow.com/questions/6152231/is-there-a-ruby-library-gem-that-will-generate-a-url-based-on-a-set-of-parameter for an explanation of the problem we faced and hopefully (!) the solution
  config.action_controller.asset_host = config.mailer_url
  config.action_mailer.asset_host = "#{'https'}://#{config.mailer_url}"

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :user_name => ENV["WCRS_FRONTEND_EMAIL_USERNAME"],
    :password => ENV["WCRS_FRONTEND_EMAIL_PASSWORD"],
    :domain => config.mailer_url,
    :address => ENV["WCRS_FRONTEND_EMAIL_HOST"],
    :port => ENV["WCRS_FRONTEND_EMAIL_PORT"],
    :authentication => :plain,
    :enable_starttls_auto => true
  }

  config.assets.precompile += %w(
    application.css
    application-ie8.css
    application-ie7.css
    application-ie6.css
    application.js
  )

  #Worldpay configuration. Use the Production service unless we want to use the test service (e.g. in staging)
  if ENV['WCRS_FRONTEND_USE_WORLDPAY_TEST_SERVICE'] == 'true'
    #Using the Worldpay TEST service in all environments - even in Production (for now at least)
    config.worldpay_uri = 'https://secure-test.worldpay.com/jsp/merchant/xml/paymentService.jsp'
  else
    #The Worldpay Production payment service is located here:
    config.worldpay_uri = 'https://secure.worldpay.com/jsp/merchant/xml/paymentService.jsp'
  end

end

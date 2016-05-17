Registrations::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  # config.whiny_nils = true

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Sending e-mails is required for user management and registration e-mails
  # config.action_mailer.default_url_options = { :host => ENV['WCRS_FRONTEND_PUBLIC_APP_DOMAIN'] }

  config.action_mailer.default_url_options = { :host => 'localhost' }
  Capybara.server_port = 3005

  # Ensures images included in emails that originate from our assest folder and pipepline
  # can still be viewed in emails. See
  # http://stackoverflow.com/questions/6152231/is-there-a-ruby-library-gem-that-will-generate-a-url-based-on-a-set-of-parameter for an explanation of the problem we faced and hopefully (!) the solution
  config.action_controller.asset_host = ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"]
  config.action_mailer.asset_host = "#{'https'}://#{ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"]}"

  # Deprecated - Raise exception on mass assignment protection for Active Record models
  # config.active_record.mass_assignment_sanitizer = :strict

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # require access via www or admin service domain URLs for testing
  config.require_admin_requests = false

  # During testing, don't redirect to an external site on log-out, so we can
  # use the Rack driver for testing.
  config.waste_exemplar_end_url = "/"
end

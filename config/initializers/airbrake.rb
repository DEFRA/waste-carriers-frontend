if ENV['WCRS_FRONTEND_USE_AIRBRAKE'] && !Rails.env.test?
  Airbrake.configure do |config|
    config.host = ENV['WCRS_FRONTEND_AIRBRAKE_HOST']
    config.project_id = ENV['WCRS_FRONTEND_AIRBRAKE_PROJECT_ID']
    config.project_key = ENV['WCRS_FRONTEND_AIRBRAKE_PROJECT_KEY']
    config.root_directory = Rails.root
    config.blacklist_keys = [/password/i]
  end
end

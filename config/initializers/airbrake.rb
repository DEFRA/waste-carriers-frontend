if ENV['WCRS_FRONTEND_USE_AIRBRAKE'] && !Rails.env.test?

  project_id = ENV['WCRS_FRONTEND_AIRBRAKE_PROJECT_ID'].to_i

  Airbrake.configure do |config|
    config.host = ENV['WCRS_FRONTEND_AIRBRAKE_HOST']
    config.project_id = project_id.zero? ? 1 : project_id
    config.project_key = ENV['WCRS_FRONTEND_AIRBRAKE_PROJECT_KEY']
    config.root_directory = Rails.root
    config.blacklist_keys = [/password/i]
  end

  Airbrake.add_filter do |notice|
    nomethoderror = proc do |error|
      error[:backtrace].empty? &&
        error[:type] == 'NoMethodError' &&
        error[:message] =~ %r{undefined method `call'}
    end

    notice.ignore! if notice[:errors].any?(&nomethoderror)
  end
end

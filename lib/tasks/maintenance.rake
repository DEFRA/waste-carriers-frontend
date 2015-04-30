namespace :maintenance do
  # Generates /public/maintenance.html for use in conjunction with the turnout
  # gem which provides the maintenance mode functionality.
  task generate: :environment do
    puts 'Generating maintenance.html for maintenance mode'

    if Registrations::Application.config.force_ssl
      url_prefix = 'https://'
    else
      url_prefix = 'http://'
    end

    # Initial versions failed because in other environments the root
    # address is localhost, not localhost:3000.
    if Rails.env.downcase == 'development'.downcase
      root_url = 'localhost:3000'
    else
      root_url = 'localhost'
    end

    puts "Will request #{url_prefix}#{root_url}/maintenance as base for page"
    system "curl -k -X GET #{url_prefix}#{root_url}/maintenance \
      -o public/maintenance.html"
  end

  # Handy alternative to calling the 'generate' and 'start' tasks seperately. It
  # ensures that the assets folder is added as an acceptable route to (needed
  # for styling to come through) and will set a default reason if none is
  # is given.
  task default: :environment do
    Rake::Task['maintenance:generate'].invoke

    # invoke() has the ability to accept arguments, but not named ones. To do
    # that we have to specify them as ENV variables first then call the rake
    # task. This checks if they were given when the task was called, setting
    # them automatically if they were blank. Also be aware args are case
    # senstive.
    if ENV['allowed_paths'].blank?
      ENV['allowed_paths'] = '/assets/*'
    else
      ENV['allowed_paths'] = "#{ENV['allowed_paths']},^/assets/*"
    end

    ENV['reason'] = "We have had to take the service offline whilst we make \
      important changes to it." if ENV['reason'].blank?

    Rake::Task['maintenance:start'].invoke
  end

  # Handy alternative to calling the 'end' task. It not only ensures that the
  # tmp/maintenance.yml is deleted which ends maintenance mode, but also deletes
  # public/maintenance.html.
  task stop: :environment do
    maintenance_file = Rails.root.join('public/maintenance.html')
    if File.exist?(maintenance_file)
      File.delete(maintenance_file)
      puts 'Deleted public/maintenance.html'
    end

    Rake::Task['maintenance:end'].invoke
  end
end

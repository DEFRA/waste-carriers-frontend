namespace :maintenance do
  # Generates /public/maintenance.html for use in conjunction with the turnout
  # gem which provides the maintenance mode functionality.
  task generate: :environment do
    puts 'Generating maintenance.html for maintenance mode'
    system 'curl -X GET http://localhost:3000/maintenance \
      -o public/maintenance.html'
  end

  # Handy alternative to calling the 'generate' and 'start' tasks seperately. It
  # will use a default reason though so cannot be used where a custom reason
  # is required.
  task default: :environment do
    Rake::Task['maintenance:generate'].invoke

    # invoke() has the ability to accept arguments, but not named ones. To do
    # that we have to specify them as ENV variables first then call the rake
    # task. Also be aware args are case senstive.
    ENV['allowed_paths'] = '/assets/*'
    ENV['reason'] = "The service is temporarily unavailable whilst we make \
      important changes to it."
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

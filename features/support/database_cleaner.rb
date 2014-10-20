begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  DatabaseCleaner.orm = 'mongoid'
  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before do
  DatabaseCleaner.start
  
  # Checks if in development mode
  if !Rails.env.production?
    puts 'Running Force delete of all registrations'
    # Manually call the services to clear down any existing regitrations
    RestClient.post Rails.configuration.waste_exemplar_services_admin_url + '/tasks/dbcleaner', :content_type => :json, :accept => :json
  end
end

After do |scenario|
  DatabaseCleaner.clean
end
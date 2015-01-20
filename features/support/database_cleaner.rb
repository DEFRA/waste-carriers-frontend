begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  DatabaseCleaner.orm = 'mongoid'
  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before do
  # Setup cleaning for the Mongo DB.
  DatabaseCleaner.start

  # Clean the Redis DB ([un]comment lines as required to prove code has desired effect).
  Ohm.redis.call "FLUSHDB"   # Cleans the Redis DB.
  #puts "Redis DB currently has #{Ohm.redis.call "DBSIZE"} keys"

  # Clean the Elastic Search database if in development environment.
  if !Rails.env.production?
    # Old version: goes via the WCR Services layer, which deletes each registration one-by-one.
    # Manually call the services to clear down any existing regitrations
    #RestClient.post Rails.configuration.waste_exemplar_services_admin_url + '/tasks/dbcleaner', :content_type => :json, :accept => :json

    # New version: direct call into ElasticSearch REST API.
    RestClient.delete "#{Rails.configuration.waste_exemplar_elasticsearch_url}/registrations/_query?q=*:*"

    loop do
      response_data = JSON.parse(RestClient.get "#{Rails.configuration.waste_exemplar_elasticsearch_url}/registrations/_count")
      break if response_data[:count].to_i == 0
      sleep 0.1
      puts "DatabaseCleaner: Sleeping for a short while whilst database is cleaned..."
    end
  end
end

After do |scenario|
  DatabaseCleaner.clean
end

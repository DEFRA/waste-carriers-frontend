begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  DatabaseCleaner[:mongoid].strategy = :truncation

rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before do
  # Setup cleaning for the Mongo DB.
  DatabaseCleaner.start

  DatabaseCleaner.clean
  clean_users_db

  # Clean the Redis DB ([un]comment lines as required to prove code has desired effect).
  Ohm.redis.call "FLUSHDB"   # Cleans the Redis DB.
  # puts "Redis DB currently has #{Ohm.redis.call "DBSIZE"} keys"

  # Clean the Elastic Search database if in development environment.
  if !Rails.env.production?

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
  # Normally you would call clean here but we have examples of scenarios failing
  # and this action not then being called. This could cause issues for subsequent
  # tests hence we moved all clean actions into the 'Before'
end

def clean_users_db

  host_url = ENV['WCRS_USERSDB_URL1']
  db_name = ENV['WCRS_USERSDB_NAME']
  user_name = ENV['WCRS_USERSDB_USERNAME']
  password = ENV['WCRS_USERSDB_PASSWORD']

  session = Moped::Session.new([ host_url ])
  session.with(database: db_name).login(user_name, password)
  session.use(db_name)

  admins = session[:admins]
  admins.drop

  agency_users = session[:agency_users]
  agency_users.drop

  users = session[:users]
  users.drop

end

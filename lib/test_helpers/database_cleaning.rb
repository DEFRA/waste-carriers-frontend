require 'database_cleaner'

module TestHelpers
  class DatabaseCleaning
    # Cleans the Mongo 'Users' DB.  This method will become obsolete
    # if Users and Registrations are migrated into a single DB.
    def self.clean_mongo_users_db
      host_url = ENV['WCRS_USERSDB_URL1']
      db_name = ENV['WCRS_USERSDB_NAME']
      user_name = ENV['WCRS_USERSDB_USERNAME']
      password = ENV['WCRS_USERSDB_PASSWORD']

      session = Moped::Session.new([ host_url ])
      session.with(database: db_name).login(user_name, password)
      session.use(db_name)

      session[:admins].drop
      session[:agency_users].drop
      session[:users].drop
    end
    
    # Cleans the Mongo database(s) used by the applicaiton.
    def self.clean_mongo
      # Use the DatabaseCleaner Gem to clean the Mongo Registrations DB.
      DatabaseCleaner.clean
      
      # Use our own Moped-based method to clean the Mongo Users DB.
      clean_mongo_users_db()
    end
    
    # Cleans the Redis database(s) used by the applicaiton.
    def self.clean_redis
      Ohm.redis.call "FLUSHDB"
      # puts "Redis DB currently has #{Ohm.redis.call "DBSIZE"} keys"      # UNCOMMENT ME TO PROVE REDIS IS BEING CLEANED.
    end
    
    # Cleans the ElasticSearch database(s) used by the application.
    def self.clean_elasticsearch
      if !Rails.env.production?
        RestClient.delete "#{Rails.configuration.waste_exemplar_elasticsearch_url}/registrations/_query?q=*:*"
        loop do
          response_data = JSON.parse(RestClient.get "#{Rails.configuration.waste_exemplar_elasticsearch_url}/registrations/_count")
          break if response_data[:count].to_i == 0
          sleep 0.1
          puts "DatabaseCleaning: Sleeping for a short while whilst database is cleaned..."
        end
      end
    end
    
    # Cleans all databases used by the application.  For use during Unit & Integration tests.
    def self.clean_all_databases
      clean_mongo()
      clean_redis()
      clean_elasticsearch()
    end
    
  end
end

require 'database_cleaner'

module TestHelpers
  class DatabaseCleaning
    # Cleans the Mongo database(s) used by the applicaiton.
    def self.clean_mongo
      # This will clean the mongoid default database, which in this case is the
      # registrations db
      DatabaseCleaner[:mongoid, {:connection => :default}]
      DatabaseCleaner.clean

      # This will setup DatabaseCleaner to then clean the users db
      DatabaseCleaner[:mongoid, {:connection => :users}]
      DatabaseCleaner.clean
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

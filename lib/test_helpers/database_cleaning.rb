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

    # Cleans all databases used by the application.  For use during Unit & Integration tests.
    def self.clean_all_databases
      clean_mongo()
      clean_redis()
    end

  end
end

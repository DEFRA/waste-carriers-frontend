# frozen_string_literal: true

namespace :db do
  namespace :mongoid do
    desc "Test the connection to MongoDb"
    task connection: :environment do
      puts "Mongoid configuration set? #{Mongoid::Config.configured?}"
      puts "Connection to MongoDb working? #{connected?}"
    end

    def connected?
      client = Mongoid::Clients.default
      client.database.collections.length
      true
    rescue StandardError => e
      puts e.message
      false
    end
  end
end

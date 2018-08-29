# frozen_string_literal: true

namespace :db do
  namespace :mongoid do

    desc "Drop all collections in all databases, including indexes."
    task purge_all: :environment do
      Mongoid::Clients.default.database.collections.each(&:drop)
      Mongoid::Clients.with_name("users").database.collections.each(&:drop)
    end

  end
end

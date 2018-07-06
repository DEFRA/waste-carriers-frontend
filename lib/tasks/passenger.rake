# frozen_string_literal: true

namespace :passenger do
  desc "Restart all processes"
  task restart: :environment do
    sh "bundle exec passenger-config restart-app --ignore-passenger-not-running /"
  end

  desc "Enable auto restart after each request"
  task enable_restart: :environment do
    sh "touch tmp/always_restart.txt"
  end

  desc "Disable auto restart after each request"
  task disable_restart: :environment do
    sh "rm tmp/always_restart.txt"
  end
end

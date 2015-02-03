begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'
  require_relative '../../lib/test_helpers/database_cleaning'

  DatabaseCleaner[:mongoid].strategy = :truncation

rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before do
  TestHelpers::DatabaseCleaning.clean_all_databases
end

After do |scenario|
  # Normally you would call clean here but we have examples of scenarios failing
  # and this action not then being called. This could cause issues for subsequent
  # tests hence we moved all clean actions into the 'Before'
end

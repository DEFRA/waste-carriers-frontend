# frozen_string_literal: true

# Require and run our simplecov initializer as the very first thing we do.
# This is as per its docs https://github.com/colszowka/simplecov#getting-started
require "./spec/support/simplecov"

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/email/rspec'
require 'webmock/rspec'
require_relative '../lib/test_helpers/database_cleaning'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
#
# We make an exception for simplecov because that will already have been
# required and run at the very top of spec_helper.rb
support_files = Dir["./spec/support/**/*.rb"].reject { |file| file == "./spec/support/simplecov.rb" }
support_files.each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Hide the deprecation warning for RSpec 3 example group spec types.
  # TODO: Remove this at some point in the future.
  config.infer_spec_type_from_file_location!

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  config.expose_current_running_example_as :example

  config.before(:each) do
    Timecop.return
  end

  config.before(:suite) do
    DatabaseCleaner.orm = 'mongoid'
    DatabaseCleaner.strategy = :truncation
  end

  # Fully clean all databases before each test.
  config.before(:each) do
    TestHelpers::DatabaseCleaning.clean_all_databases
  end

  # Fully clean all databases after all tests have finished running.
  config.after(:suite) do
    TestHelpers::DatabaseCleaning.clean_all_databases
  end

  # Make our generic test helpers available to all unit tests.
  config.include Helpers
end

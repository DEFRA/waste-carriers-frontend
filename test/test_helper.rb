ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting

  # Note: fixtures seem not well supported when using ActiveResource (vs. ActiveRecord). Getting error 'undefined method ... quote_table_name' otherwise...
  #fixtures :all

  # Add more helper methods to be used by all tests here...
end

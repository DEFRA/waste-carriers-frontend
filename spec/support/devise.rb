# This file is required in projects that use devise but also wish to test controllers.
# We identified this when I encountered this issue:
# http://stackoverflow.com/questions/4308094/all-ruby-tests-raising-undefined-method-authenticate-for-nilnilclass
# Adding this file and what it should contain is covered here:
# https://github.com/plataformatec/devise#test-helpers

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
end

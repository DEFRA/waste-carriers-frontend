source 'https://rubygems.org'
#Needed for pre-release gov.uk gems
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rails', '4.0.0'

gem 'debugger', :require => false

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#We won't need sqllite (or ActiveRecord) once we have moved to ActiveResource for registrations
#but it may still be need it for authentication...
gem 'sqlite3'

#Using devise for authentication
gem 'devise', '~>3.1.1'

#Using cancan for authorisation
gem "cancan", "~> 1.6.10"

# Use ActiveResource, this app being the client of the REST-based service API (implemented in waste-exemplar-services)
gem 'activeresource', '~>4.0.0'


gem 'govuk_frontend_toolkit'

# Gems used only for assets and not required
# in production environments by default.

gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby

gem 'uglifier', '>= 1.3.0'


gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano', '~> 3.0.0'

# To use debugger
# gem 'debugger'

group :test do
  gem 'ci_reporter'
end 

group :test, :development do
  gem 'cucumber-rails', :require => false
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'

  #We need the selenium webdriver for javascript
  gem 'selenium-webdriver'

  #needed for headless testing with Javascript
  gem 'capybara-webkit'
end

#cross-browser testing using saucelabs
group :test, :development do
  gem 'rspec-rails', '~> 2.12'
  gem 'sauce', '~> 3.2.0'
  gem 'sauce-connect', :require => false
  gem 'sauce-cucumber', :require => false
  gem 'capybara', '~> 2.1.0'
  gem 'parallel_tests', :require => false
end

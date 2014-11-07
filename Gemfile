source 'https://rubygems.org'
#Needed for pre-release gov.uk gems
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rails', '4.0.10'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#We store user accounts (authentication with Devise) in a MongoDB database
gem 'mongoid', '~> 4.0.0'

#Using devise for authentication
gem 'devise', '~> 3.1.1'

#Using cancan for authorisation
gem "cancan", "~> 1.6.10"

# Use ActiveResource, this app being the client of the REST-based service API (implemented in waste-exemplar-services)
gem 'activeresource', '~>4.0.0'
gem 'password_strength', '~>0.3.2'

gem 'rolify'

gem 'indefinite_article'

# Provided by GDS - Template gives us the master layout into which
# we can inject our content using yield and content_for
gem 'govuk_template'
# Access to some of the most common styles and scripts used by GDS
gem 'govuk_frontend_toolkit'

# Gems used only for assets and not required
# in production environments by default.

# Using Nokogiri for parsing XML retrieved from WorldPay
gem 'nokogiri', '~> 1.6.2.1'

gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'

gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'turbolinks'

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

gem 'rest-client'
gem 'ohm'

gem 'money-rails'
gem 'monetize'

# For static source code analysis
gem 'brakeman', :require => false
gem 'bundler-audit', :require => false

group :test do
  gem 'ci_reporter', '~> 1.9.0'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner', '~> 1.3.0'
  gem 'timecop', '~> 0.7.1'
  gem 'factory_girl_rails', '~> 4.4.1'
  gem 'shoulda-matchers'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  gem 'letter_opener', '~> 1.2.0'
  gem 'meta_request', '~> 0.3.4'   #gem needed for Chrome's RailsPanel plugin
end

group :test, :development do
  #We need the selenium webdriver for javascript
  gem 'selenium-webdriver'

  #needed for headless testing with Javascript
  gem 'capybara-webkit'
  gem 'capybara-email', '~> 2.2.0'

  gem "launchy", "~> 2.4.2", :require => false
  gem 'rspec-rails', '~> 2.12'

  #cross-browser testing using saucelabs
  gem 'sauce'
  gem 'sauce-connect', :require => false
  gem 'sauce-cucumber', :require => false
  gem 'capybara', '~> 2.1.0'
  gem 'parallel_tests', :require => false
end

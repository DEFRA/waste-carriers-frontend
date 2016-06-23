source 'https://rubygems.org'
#ruby=2.0.0-p645
#ruby-gemset=waste-exemplar-frontend

# Needed for pre-release gov.uk gems - not needed anymore?
# source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rails', '4.0.12'

# For exception logging.
gem 'airbrake', '~> 5.3'

# We store user accounts (authentication with Devise) in a MongoDB database
gem 'mongoid', '~> 4.0.0'

# Using devise for authentication
gem 'devise', '~> 3.1.1'

# Using cancan for authorisation
gem 'cancan', '~> 1.6.10'

# Use ActiveResource, this app being the client of the REST-based service API
# (implemented in waste-exemplar-services)
gem 'activeresource', '~>4.0.0'

gem 'rolify', '~> 3.4.0'

gem 'indefinite_article', '~> 0.2.0'

# Provided by GDS - Template gives us the master layout into which
# we can inject our content using yield and content_for
gem 'govuk_template', '~> 0.10.0'
# Access to some of the most common styles and scripts used by GDS
gem 'govuk_frontend_toolkit', '~> 2.0.1'

# Gems used only for assets and not required
# in production environments by default.

# Using Nokogiri for parsing XML retrieved from WorldPay
gem 'nokogiri', '~> 1.6.2.1'

gem 'sass-rails',   '~> 4.0.3'
gem 'coffee-rails', '~> 4.0.0'

gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'turbolinks'

# Deploy with Capistrano
gem 'capistrano', '~> 3.0.0'

gem 'rest-client', '~> 1.6.7'
gem 'ohm', '~> 2.0.1'

gem 'money-rails', '~> 0.12.0'
gem 'monetize', '~> 0.3.0'

# Simplifies some Google Analytics work.
gem 'json', '>= 1.8.0'

# Added to give us maintenance mode functionality i.e. the service presents
# a maintenance page to any users when switched on
gem 'turnout', '~> 2.1.0'

# Added and used to translate the country entered by a user to a 2 digit code
# which is then passed to Worldpay
gem 'countries'

# Provides the 'ap' method which is like puts, but pretty prints objects to the console
gem 'awesome_print'

# Generates a PDF from HTML, in our case, the users certificate
# If you don't have wkhtmltopdf installed on Ubuntu run this:
# sudo apt-get install ttf-mscorefonts-installer wkhtmltopdf
gem 'wicked_pdf'

# Allows colorized output to the console
gem 'colorize'

group :test do
  gem 'ci_reporter', '~> 1.9.0'
  gem 'cucumber-rails', '~> 1.4.0', require: false
  gem 'database_cleaner', '~> 1.3.0'
  gem 'timecop', '~> 0.7.1'
  gem 'factory_girl_rails', '~> 4.4.1'
  gem 'shoulda-matchers'
  gem 'vcr'
  gem 'webmock'
  gem 'faker', '~> 1.4.3'
  gem 'simplecov', require: false
  gem 'simplecov-json', require: false
  gem 'simplecov-rcov', require: false
  gem 'show_me_the_cookies'
end

group :development do
  # For static source code analysis
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false

  gem 'letter_opener', '~> 1.2.0'

  # gem needed for Chrome's RailsPanel plugin
  gem 'meta_request'

  # Hide assets in development server log
  gem 'quiet_assets'

  # Dependency of better errors
  gem 'binding_of_caller'
  # Intercepts exceptions in development and displays an interactive debug console within the browser
  gem 'better_errors'
end

group :test, :development do

  # Needed for headless testing with Javascript or pages that ref external sites
  gem 'poltergeist', '~> 1.6.0'
  gem 'capybara-email', '~> 2.2.0'

  gem 'launchy', '~> 2.4.2', require: false
  gem 'rspec-rails', '~> 2.12'

  gem 'capybara', '~> 2.1.0'
  gem 'selenium-webdriver', '~> 2.44.0'
  gem 'chromedriver-helper', '~> 0.0.8'

  # Required to populate the database with load-test data for Convictions.
  gem 'elasticsearch-persistence', '~> 0.1.6'
  gem 'ruby-progressbar', '>= 1.7.1'

  # Development web server
  gem 'thin'

  # Load environment variables from .env
  gem 'dotenv-rails'

  # Interactive debug tool
  gem 'byebug'
end

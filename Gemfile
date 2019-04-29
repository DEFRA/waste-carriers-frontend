source 'https://rubygems.org'
ruby "2.4.2"

gem "rails", "~> 4.2.11"

# For exception logging.
gem 'airbrake', '~> 5.3'

# We store user accounts (authentication with Devise) in a MongoDB database
# This version of mongoid supports MongoDb 3.6
gem "mongoid", "~> 5.2.0"

# Using devise for authentication
gem "devise", ">= 4.4.3"

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

gem 'sass-rails',   '~> 4.0.3'
gem 'coffee-rails', '~> 4.0.0'

gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails'

gem "rest-client", "~> 2.0"
gem 'ohm', '~> 3.0.0'

gem 'money-rails'
gem 'monetize'

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

# Allows us to automatically generate the change log from the tags, issues,
# labels and pull requests on GitHub. Added as a dependency so all dev's have
# access to it to generate a log, and so they are using the same version.
# New dev's should first create GitHub personal app token and add it to their
# ~/.bash_profile (or equivalent)
# https://github.com/skywinder/github-changelog-generator#github-token
# Then simply run `bundle exec rake changelog` to update CHANGELOG.md
# Should be in the :development group however when it is it breaks deployment
# to Heroku. Hence moved outside group till we can understand why.
gem "github_changelog_generator", require: false

# Defines a route for ELB healthchecks. The healthcheck is a piece of Rack
# middleware that does absolutely nothing, so it is faster than just using the
# default `/` route, or `/version` as was previously used.
# The app now returns a 200 from `/healthcheck`
# Test with `curl -I http://localhost:3000/healthcheck`
gem 'aws-healthcheck'

group :production do
  # Web application server that replaces webrick. It handles HTTP requests,
  # manages processes and resources, and enables administration, monitoring
  # and problem diagnosis. It is used in production because it gives us an ability
  # to scale by creating additional processes, and will automatically restart any
  # that fail. We don't use it when running tests for speed's sake.
  gem "passenger", "~> 5.0", ">= 5.0.30", require: "phusion_passenger/rack_handler"
end

group :test do
  gem 'cucumber-rails', '~> 1.6.0', require: false
  gem 'database_cleaner', '~> 1.7.0'
  gem 'timecop', '~> 0.7.1'
  gem 'factory_girl_rails', '~> 4.4.1'
  gem 'shoulda-matchers', '~> 2.8.0'
  gem 'vcr'
  gem "webmock", "~> 3.3"
  gem 'faker'
  gem 'simplecov', require: false
end

group :development do
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
  gem 'capybara-email', '~> 2.4'

  gem 'launchy', '~> 2.4.2', require: false
  gem "rspec-rails", "~> 3.6"

  gem 'capybara', '~> 2.4'
  gem 'selenium-webdriver', '~> 2.44.0'
  gem 'chromedriver-helper', '~> 0.0.8'

  gem 'ruby-progressbar', '>= 1.7.1'

  # Load environment variables from .env
  gem 'dotenv-rails'

  # Call "binding.pry" anywhere in the code to stop execution and get a debugger console
  gem "pry-byebug"
end

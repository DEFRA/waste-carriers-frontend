#waste-exemplar-frontend

Waste Carriers Registration Service Frontend application.

The Waste Carrier Registrations Service allows businesses, who deal with waste and thus have to register according to the regulations, to register online. Once registered, businesses can sign in again to edit their registrations if needed.

The service also allows authorised agency users and NCCC contact centre staff to create and manage registrations on other users behalf, e.g. to support 'Assisted Digital' registrations. The service provides an internal user account management facility which allows authorised administrators to create and manage other agency user accounts.

The service is implemented as a frontend web application, with a service API and a document-oriented database (MongoDB) underneath.

The frontend application is a Ruby on Rails 4 application, which accesses a RESTful services layer implemented in Java.
The services layer provides a RESTful API to manage (create, read, update, delete) registrations.
The service layer in turn accesses a MongoDB database. 

For authentication purposes the application uses the Devise gem (https://github.com/plataformatec/devise) to manage the user accounts of waste carriers (i.e. external users), and internal users (agency users such as NCCC contact centre staff and administrators). User account information managed by the Devise gem is stored in MongoDB.

It is expected that external user authentication will be migrated to mechanisms provided by the GOV.UK ID Assurance program, once these become available (thought to be in 2014).

The application sends emails using the Sendgrid e-mail service.


##Installation


Clone the repository, copying the project into a working directory:

	$ git clone https://github.com/EnvironmentAgency/waste-exemplar-frontend.git

##Configuration

The application contains a variety of configurable settings, which are set in several files located in the /config directory.
Environment-related configuration settings are located in the /config/environments directory, e.g. development.rb, production.rb, etc.

The frontend application expects the services to run on http://localhost:9090, unless configured otherwise.

You may want or need to set the following environment variables, e.g. in your ~/.bash_profile (if you are a Mac or Linux user):

	## Sendgrid configuration
	export WCRS_FRONTEND_EMAIL_USERNAME="<your sendgrid username here>"
	export WCRS_FRONTEND_EMAIL_PASSWORD="<your sendgrid password here>"
	export WCRS_FRONTEND_EMAIL_HOST="smtp.sendgrid.net"
	export WCRS_FRONTEND_EMAIL_PORT=25
	export WCRS_FRONTEND_WCRS_SERVICES_URL="http://localhost:9090"
	export WCRS_FRONTEND_PUBLIC_APP_DOMAIN="www.local.wastecarriersregistration.service.gov.uk"
	export WCRS_FRONTEND_ADMIN_APP_DOMAIN="admin.local.wastecarriersregistration.service.gov.uk"
	export WCRS_FRONTEND_USERSDB_NAME="waste-carriers"
	export WCRS_FRONTEND_USERSDB_USERNAME=mongoUser
	export WCRS_FRONTEND_USERSDB_PASSWORD=<your mongo password here>
	export WCRS_FRONTEND_USERSDB_URL=localhost:27017
	export WCRS_FRONTEND_USERSDB_URL2=localhost:28017
	export WCRS_FRONTEND_USERSDB_URL3=localhost:29017
	##for Saucelabs cross-browser testing:
	export SAUCE_USERNAME=***REMOVED***
	export SAUCE_ACCESS_KEY=***REMOVED***

You may want to edit your local 'hosts' file to have entries for "www.local.wastecarriersregistration.service.gov.uk" and "admin.local.wastecarriersregistration.service.gov.uk".


##Prerequisites


* Git
* Access to GitHub
* Ruby 2.0.0
	* recommended: use RVM - the Ruby Version Manager
* Rails 4.0
* The running services layer (build and deploy waste-exemplar-services)
* Java 7 JDK - for building the services layer
* Maven (version 3.0 or above) - for building the services layer
* MongoDB (version 2.4.6 or above) - to store registrations and user accounts
* ElasticSearch (version 0.90.5 or above) - for full-text search


##Build and Deploy

As is standard with Rails applications, navigate to the project directory, and execute the following:

Install missing gems:

	$ bundle install

Start the Rails application web server:

	$ rails server

This will start the Rails development server (in development mode), by default on port 3000 (http://localhost:3000).

Once the application server is started you should be able to access the application in your browser on

	http://localhost:3000

##User Guide

While in development, the application contains a (temporary) root index page which shows a variety of links for the typical entry points into the application. Note: this page may be removed at a later stage.

##Run Tests

###Acceptance Tests - using Cucumber

To run the Cucumber-based acceptance tests, navigate to the application project directory, and execute from the command line / Terminal window:

	$ cucumber

Acceptance tests are located in the features directory.


###Cross-Browser Tests

We use Saucelabs to run cross-browser and cross-platform tests.
Saucelabs supports a variety of languages and testing frameworks, including RSpec and Cucumber for Ruby and Rails based development.

Cucumber-based tests are work-in-progress and sometimes fail due to connectivity and timeout problems. 

To run the Cucumber-based tests against Saucelabs, execute:

	$ rake sauce:features


To run RSpec-based tests against Saucelabs, execute:

	$ rake sauce:spec


##Related Resources

Ruby on Rails: http://rubyonrails.org

MongoDB: http://www.mongodb.org

ElasticSearch: http://www.elasticsearch.org

Apache Maven: http://www.elasticsearch.org


##License

TBD

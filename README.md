waste-exemplar-frontend
=======================

Waste Carriers Registration Service Frontend application.

The frontend application is a Ruby on Rails 4 application, which accesses a RESTful services layer implemented in Java.
The service layer in turn accesses a MongoDB database.

Installation
------------

Clone the repository, copying the project into a working directory:


Configuration
-------------


Prerequisites
-------------

* Git
* Access to GitHub
* Ruby 2.0.0
* Rails 4.0
* The running services layer (build and deploy waste-exemplar-services)
* MongoDB (version 2.4.6 or above)
* ElasticSearch (version 0.90.5 or above)


Build and Deploy
----------------

As is standard with Rails applications, navigate to the project directory, and execute the following:

Install missing gems:

$ bundle install

Start the Rails application web server:

$ rails server

This will start the Rails development server (in development mode), by default on port 3000 (http://localhost:3000).

Once the application server is started you can access the application on

http://localhost:3000

User Guide
----------


Run Tests
---------

To run the Cucumber-based acceptance tests, navigate to the application project directory execute from the command line / Terminal window:

$ cucumber

Related Resources
-----------------




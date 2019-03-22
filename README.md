# Waste carriers frontend

[![Build Status](https://travis-ci.com/DEFRA/waste-carriers-frontend.svg?branch=master)](https://travis-ci.com/DEFRA/waste-carriers-frontend)
[![Maintainability](https://api.codeclimate.com/v1/badges/54a95cbae5d7ddcc20b7/maintainability)](https://codeclimate.com/github/DEFRA/waste-carriers-frontend/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/54a95cbae5d7ddcc20b7/test_coverage)](https://codeclimate.com/github/DEFRA/waste-carriers-frontend/test_coverage)
[![security](https://hakiri.io/github/DEFRA/waste-carriers-frontend/master.svg)](https://hakiri.io/github/DEFRA/waste-carriers-frontend/master)
[![Licence](https://img.shields.io/badge/Licence-OGLv3-blue.svg)](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3)

The Waste Carrier Registrations Service allows businesses, who deal with waste and thus have to register according to the regulations, to register online. Once registered, businesses can sign in again to edit their registrations if needed.

The service also allows authorised agency users and NCCC contact centre staff to create and manage registrations on a user's behalf, e.g. to support 'Assisted Digital' registrations. The service provides an internal user account management facility which allows authorised administrators to create and manage other agency user accounts.

The service is implemented as a frontend web application, with a service API and a document-oriented database (MongoDB) underneath.

- The frontend application is a Ruby on Rails 4 application, which accesses a RESTful services layer implemented in Java.
- The services layer provides a RESTful API to manage (create, read, update, delete) registrations.
- The service layer in turn accesses a MongoDB database.

For authentication purposes the application uses the Devise gem (https://github.com/plataformatec/devise) to manage the user accounts of waste carriers (i.e. external users), and internal users (agency users such as NCCC contact centre staff and administrators). User account information managed by the Devise gem is stored in MongoDB.

The application sends emails using the [Sendgrid](https://sendgrid.com/) e-mail service.

## Prerequisites

- Ruby 2.4.2
- Redis (version 2.8.x) - for temporary session storage
- MongoDb (version 3.6) - to store registrations and user accounts

## Installation

Clone the repo and drop into the project

```bash
git clone https://github.com/DEFRA/waste-carriers-frontend.git && cd waste-carriers-frontend
```

Then install the dependencies `bundle install`.

## Running locally

A [Vagrant instance](https://www.vagrantup.com/) has been created allowing easy setup of the waste carriers service. It includes installing all applications, databases and dependencies. This is located within Gitlab (speak to the ruby team).

Download the vagrant project and create the VM using the instructions in its README. It includes installing and running a version of the frontend app, however if you intend to work with it locally and just use the box for dependencies you'll need to:

- Login into the vagrant instance then using `ps ax` identify the pid of the running frontend app
- Kill it using `kill [pid id]`
- Exit the vagrant instance

Once you've created a `.env` file (see below) you should be reading to work with and run the project locally.

## Configuration

Most settings are driven through environment variables as per [12 factor app](https://12factor.net/config), however when working locally we use [Dotenv](https://github.com/bkeepers/dotenv) and a `.env` file to load them. This saves having to add them to each session or update your `~/.bash_profile`. See `.env.example` for details of the environment variables that can be set. Also check the environment files as detailed above, because in some cases a default will be used negating the need to set the environment variable.

## wkhtmltopdf

We use wkhtmltopdf to create PDF files. On Ubuntu this can be installed with

`sudo apt-get install wkhtmltopdf`

## User Guide

While in development, the application contains a (temporary) root index page which shows a variety of links for the typical entry points into the application.

## Testing the app

### Unit Tests

RSpec unit tests are available. Run `bundle exec rspec` to run all tests.

Unit tests aree located in the `spec` directory.

### Feature Tests

Cucumber feature tests are available. Run `bundle exec cucumber` to run all tests.

Feature tests are located in the `features` directory.

## Related Resources

- [Ruby on Rails](http://rubyonrails.org)
- [MongoDB](http://www.mongodb.org)
- [Apache Maven](https://maven.apache.org/)
- [Redis](http://redis.io)

## Contributing to this project

Please read the [contribution guidelines](/CONTRIBUTING.md) before submitting a pull request.

## License

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

<http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3>

The following attribution statement MUST be cited in your products and applications when using this information.

>Contains public sector information licensed under the Open Government license v3

### About the license

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable information providers in the public sector to license the use and re-use of their information under a common open licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.

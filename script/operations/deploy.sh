#!/bin/bash --login
#set -x

## This script will deploy and start the we-services application.
## Please refer to README.deploy for futher details.

function env_alert() {
    echo "Environment variable $1 is not set."
    echo "Please set the required environment variable and try again. Exiting now."
    echo ""
    exit 2
}

DATESTAMP=`date +%Y.%m.%d-%H.%M`
WCRS_FRONTEND_RUBY_VERSION="ruby-2.0.0-p598" ## TODO this is currently hardcoded but could get it from RVM

echo ""
echo "Running Frontend deploy.sh script"

## Ensure required environment variables have been set.
if [[ -z "${WCRS_FRONTEND_RAILS_ENV}" ]]; then env_alert WCRS_FRONTEND_RAILS_ENV; fi
if [[ -z "${WCRS_FRONTEND_HOME}" ]]; then env_alert WCRS_FRONTEND_HOME; fi
if [[ -z "${WCRS_FRONTEND_SOURCE}" ]]; then env_alert WCRS_FRONTEND_SOURCE; fi
if [[ -z "${WCRS_FRONTEND_EMAIL_HOST}" ]]; then env_alert WCRS_FRONTEND_EMAIL_HOST; fi
if [[ -z "${WCRS_FRONTEND_EMAIL_PORT}" ]]; then env_alert WCRS_FRONTEND_EMAIL_PORT; fi
if [[ -z "${WCRS_FRONTEND_EMAIL_USERNAME}" ]]; then env_alert WCRS_FRONTEND_EMAIL_USERNAME; fi
if [[ -z "${WCRS_FRONTEND_EMAIL_PASSWORD}" ]]; then env_alert WCRS_FRONTEND_EMAIL_PASSWORD; fi
if [[ -z "${WCRS_FRONTEND_WCRS_SERVICES_URL}" ]]; then env_alert WCRS_FRONTEND_WCRS_SERVICES_URL; fi
if [[ -z "${WCRS_FRONTEND_PUBLIC_APP_DOMAIN}" ]]; then env_alert WCRS_FRONTEND_PUBLIC_APP_DOMAIN; fi
if [[ -z "${WCRS_FRONTEND_ADMIN_APP_DOMAIN}" ]]; then env_alert WCRS_FRONTEND_ADMIN_APP_DOMAIN; fi
if [[ -z "${WCRS_REGSDB_NAME}" ]]; then env_alert WCRS_REGSDB_NAME; fi
if [[ -z "${WCRS_REGSDB_USERNAME}" ]]; then env_alert WCRS_REGSDB_USERNAME; fi
if [[ -z "${WCRS_REGSDB_PASSWORD}" ]]; then env_alert WCRS_REGSDB_PASSWORD; fi
if [[ -z "${WCRS_REGSDB_URL1}" ]]; then env_alert WCRS_REGSDB_URL1; fi
if [[ -z "${WCRS_REGSDB_URL2}" ]]; then env_alert WCRS_REGSDB_URL2; fi
if [[ -z "${WCRS_USERSDB_NAME}" ]]; then env_alert WCRS_USERSDB_NAME; fi
if [[ -z "${WCRS_USERSDB_USERNAME}" ]]; then env_alert WCRS_USERSDB_USERNAME; fi
if [[ -z "${WCRS_USERSDB_PASSWORD}" ]]; then env_alert WCRS_USERSDB_PASSWORD; fi
if [[ -z "${WCRS_USERSDB_URL1}" ]]; then env_alert WCRS_USERSDB_URL1; fi
if [[ -z "${WCRS_USERSDB_URL2}" ]]; then env_alert WCRS_USERSDB_URL2; fi
if [[ -z "${WCRS_ELASDB_URL_REST}" ]]; then env_alert WCRS_ELASDB_URL_REST; fi
if [[ -z "${WCRS_REGISTRATION_EXPIRES_AFTER}" ]]; then env_alert WCRS_REGISTRATION_EXPIRES_AFTER; fi
if [[ -z "${WCRS_REGISTRATION_RENEWAL_WINDOW}" ]]; then env_alert WCRS_REGISTRATION_RENEWAL_WINDOW; fi

## Stop nginx.
echo "Stopping nginx."
sudo service nginx stop

## Backup the current database.

## Create a new release directory.
if [ -f "${WCRS_FRONTEND_SOURCE}/jenkins_build_number" ]; then
  JENKINS_BUILD_NUMBER=`cat ${WCRS_FRONTEND_SOURCE}/jenkins_build_number`
else
  JENKINS_BUILD_NUMBER="j"
fi
RELEASE_DIR="wcrs-frontend-${JENKINS_BUILD_NUMBER}-${DATESTAMP}"
echo "Creating new release directory ${RELEASE_DIR}"
mkdir "${WCRS_FRONTEND_HOME}/${RELEASE_DIR}"
cd "${WCRS_FRONTEND_HOME}"
if [ -d "${WCRS_FRONTEND_HOME}/live" ]; then
  rm live
fi
ln -s "${RELEASE_DIR}" live

## Deploy the new code.
echo "Copying new code to ${WCRS_FRONTEND_HOME}/${RELEASE_DIR}/"
cp -pr ${WCRS_FRONTEND_SOURCE}/* "${WCRS_FRONTEND_HOME}/${RELEASE_DIR}/"

## Create a backup of the codedrop if on the dev server.
if [ ! -d "${WCRS_FRONTEND_HOME}/baselines" ]; then
  mkdir "${WCRS_FRONTEND_HOME}/baselines"
fi
if [ `uname -n` == "ea-dev" ]; then
  echo "Tarring up this codedrop for deploys to other servers. You can find it here:"
  echo "    ${WCRS_FRONTEND_HOME}/baselines/codedrop-wcrs-frontend-${JENKINS_BUILD_NUMBER}-${DATESTAMP}.tgz"
  cd "${WCRS_FRONTEND_SOURCE}"
  tar -zcf "${WCRS_FRONTEND_HOME}/baselines/codedrop-wcrs-frontend-${JENKINS_BUILD_NUMBER}-${DATESTAMP}.tgz" *
fi

## Bundle
echo "Installing bundle."
cd "${WCRS_FRONTEND_HOME}/live"
rvm use "${WCRS_FRONTEND_RUBY_VERSION}"
gem install rails -v '4.0.12'
bundle clean --force
bundle install

echo "Migrating database changes, if any."
rake db:migrate RAILS_ENV="${WCRS_FRONTEND_RAILS_ENV}"

## Start nginx.
echo "Starting nginx."
sudo service nginx start

## Test.
if [ ${WCRS_FRONTEND_RAILS_ENV} != "production" -a ${WCRS_FRONTEND_RAILS_ENV} != "development" ]; then
  # Wanted to use the -e option to stop the build if RSpec tests fail, but this would also stop publishing test reports further down
  # set -e
  echo "Running tests."
  rake db:test:prepare
  echo "Running unit tests (using rspec)"
  rm -rf ${WCRS_FRONTEND_HOME}/live/spec/reports/*
  rake spec
  echo "Running integration tests (using cucumber)"
  bundle exec cucumber -f json -o ${WCRS_FRONTEND_HOME}/live/features/reports/cucumber.json
fi

## Seed the database after tests have cleared the database
if [ ${WCRS_FRONTEND_RAILS_ENV} == "development" -o ${WCRS_FRONTEND_RAILS_ENV} == "test" -o ${WCRS_FRONTEND_RAILS_ENV} == "sandbox" ]; then
  echo "Seeding the database."
  rake db:seed
fi

if [ "${WCRS_FRONTEND_RAILS_ENV}" != "development" ]; then
  echo "Copying RSpec reports to Jenkins"
  scp -rp ${WCRS_FRONTEND_HOME}/live/spec/reports \
      jenkins@ea-build:/caci/jenkins/jobs/waste-exemplar-frontend/workspace/spec/
  echo "Copying cucumber report to Jenkins."
  scp ${WCRS_FRONTEND_HOME}/live/features/reports/cucumber.json \
      jenkins@ea-build:/caci/jenkins/jobs/waste-exemplar-frontend/workspace/features/reports/
fi

exit 0

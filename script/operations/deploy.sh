#!/bin/bash --login
#set -x

## This script will deploy and start the we-services application.
## Please refer to README.deploy for futher details.

function env_alert() {
    echo "Environment variable $1 is not set."
    echo "Refer to the README.deploy file for more details."
    echo "Please set the required environment variable and try again. Exiting now."
    echo ""
    exit 2
}

DATESTAMP=`date +%Y.%m.%d-%H.%M`
WCRS_FRONTEND_RUBY_VERSION="ruby-2.0.0-p247" ## TODO this is currently hardcoded but could get it from RVM

echo ""

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
if [[ -z "${WCRS_FRONTEND_USERSDB_NAME}" ]]; then env_alert WCRS_FRONTEND_USERSDB_NAME; fi
if [[ -z "${WCRS_FRONTEND_USERSDB_USERNAME}" ]]; then env_alert WCRS_FRONTEND_USERSDB_USERNAME; fi
if [[ -z "${WCRS_FRONTEND_USERSDB_PASSWORD}" ]]; then env_alert WCRS_FRONTEND_USERSDB_PASSWORD; fi
if [[ -z "${WCRS_FRONTEND_USERSDB_URL}" ]]; then env_alert WCRS_FRONTEND_USERSDB_URL; fi

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
bundle install

echo "Migrating database changes, if any."
rake db:migrate RAILS_ENV="${WCRS_FRONTEND_RAILS_ENV}"

## Seed the database as long as we're not in a production environment.
if [ ${WCRS_FRONTEND_RAILS_ENV} == "development" -o ${WCRS_FRONTEND_RAILS_ENV} == "test" ]; then
  echo "Seeding the database."
  rake db:seed
fi

## Start nginx.
echo "Starting nginx."
sudo service nginx start

## Test.
if [ "${WCRS_FRONTEND_RAILS_ENV}" != "production" ]; then
  # Wanted to use the -e option to stop the build if RSpec tests fail, but this would also stop publishing test reports further down
  # set -e
  echo "Running tests."
  rake db:test:prepare
  echo "Running unit tests (using rspec)"
  rake spec SPEC_OPTS=". --tag ~sauce"
  echo "Running integration tests (using cucumber)"
  xvfb-run cucumber -f json -o ${WCRS_FRONTEND_HOME}/live/features/reports/cucumber.json
fi

## re-Seed the database again after tests have cleared the database
if [ ${WCRS_FRONTEND_RAILS_ENV} == "development" -o ${WCRS_FRONTEND_RAILS_ENV} == "test" ]; then
  echo "Re-seeding the database."
  rake db:seed
fi

if [ "${WCRS_FRONTEND_RAILS_ENV}" == "development" ]; then
  echo "Copying RSpec reports to Jenkins"
  #TODO How to copy with wildcards???
  scp ${WCRS_FRONTEND_HOME}/live/spec/reports/SPEC-Registration-lower-.xml \
      jenkins@ea-build:/caci/jenkins/jobs/waste-exemplar-frontend/workspace/spec/reports/  
  echo "Copying cucumber report to Jenkins."
  scp ${WCRS_FRONTEND_HOME}/live/features/reports/cucumber.json \
      jenkins@ea-build:/caci/jenkins/jobs/waste-exemplar-frontend/workspace/features/reports/
fi

exit 0


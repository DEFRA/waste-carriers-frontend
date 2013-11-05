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
WCRS_FRONTEND_RUBY_VERSION="ruby-2.0.0-p247"

echo ""

## Ensure required environment variables have been set.
if [[ -z "${WCRS_FRONTEND_RAILS_ENV}" ]]; then env_alert WCRS_FRONTEND_RAILS_ENV; fi
if [[ -z "${WCRS_FRONTEND_HOME}" ]]; then env_alert WCRS_FRONTEND_HOME; fi
if [[ -z "${WCRS_FRONTEND_SOURCE}" ]]; then env_alert WCRS_FRONTEND_SOURCE; fi
if [[ -z "${WCRS_FRONTEND_SQLITE_FILE}" ]]; then env_alert WCRS_FRONTEND_SQLITE_FILE; fi
if [[ -z "${WCRS_FRONTEND_EMAIL_HOST}" ]]; then env_alert WCRS_FRONTEND_EMAIL_HOST; fi
if [[ -z "${WCRS_FRONTEND_EMAIL_PORT}" ]]; then env_alert WCRS_FRONTEND_EMAIL_PORT; fi
if [[ -z "${WCRS_FRONTEND_EMAIL_USERNAME}" ]]; then env_alert WCRS_FRONTEND_EMAIL_USERNAME; fi
if [[ -z "${WCRS_FRONTEND_EMAIL_PASSWORD}" ]]; then env_alert WCRS_FRONTEND_EMAIL_PASSWORD; fi
if [[ -z "${WCRS_FRONTEND_WCRS_SERVICES_URL}" ]]; then env_alert WCRS_FRONTEND_WCRS_SERVICES_URL; fi
if [[ -z "${WCRS_FRONTEND_PUBLIC_APP_DOMAIN}" ]]; then env_alert WCRS_FRONTEND_PUBLIC_APP_DOMAIN; fi
#if [[ -z "${WCRS_FRONTEND_ADMIN_APP_DOMAIN}" ]]; then env_alert WCRS_FRONTEND_ADMIN_APP_DOMAIN; fi

## Stop nginx.
echo "Stopping nginx."
sudo service nginx stop

## Backup the current database.
if [ -f "${WCRS_FRONTEND_HOME}/live/db/${WCRS_FRONTEND_SQLITE_FILE}" ]; then
  echo "Backing up current database."
  cd "${WCRS_FRONTEND_HOME}/live/db" 
  tar zcf "${WCRS_FRONTEND_SQLITE_FILE}-${DATESTAMP}.tgz" "${WCRS_FRONTEND_SQLITE_FILE}"
  if [ $? -ne 0 ]; then
    echo "ERROR: Backup of ${WCRS_FRONTEND_SQLITE_FILE} failed."
    echo "       Exiting now. Nginx is stopped. No new code has been deployed."
    exit 2
  fi
fi

## Create a new release directory.
RELEASE_DIR="wcrs-frontend-${DATESTAMP}"
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

## Replace environment variables.
echo "Setting environment variables in files."
sed -i "s/WCRS_FRONTEND_WCRS_SERVICES_URL/${WCRS_FRONTEND_WCRS_SERVICES_URL}/g" \
       "${WCRS_FRONTEND_HOME}/${RELEASE_DIR}/config/application.rb"
sed -i "s/WCRS_FRONTEND_PUBLIC_APP_DOMAIN/${WCRS_FRONTEND_PUBLIC_APP_DOMAIN}/g" \
       "${WCRS_FRONTEND_HOME}/${RELEASE_DIR}/config/environments/development.rb"
sed -i "s/WCRS_FRONTEND_EMAIL_HOST/${WCRS_FRONTEND_EMAIL_HOST}/g" \
       "${WCRS_FRONTEND_HOME}/${RELEASE_DIR}/config/environments/development.rb"
sed -i "s/WCRS_FRONTEND_EMAIL_PORT/${WCRS_FRONTEND_EMAIL_PORT}/g" \
       "${WCRS_FRONTEND_HOME}/${RELEASE_DIR}/config/environments/development.rb"
sed -i "s/WCRS_FRONTEND_EMAIL_USERNAME/${WCRS_FRONTEND_EMAIL_USERNAME}/g" \
       "${WCRS_FRONTEND_HOME}/${RELEASE_DIR}/config/environments/development.rb"
sed -i "s/WCRS_FRONTEND_EMAIL_PASSWORD/${WCRS_FRONTEND_EMAIL_PASSWORD}/g" \
       "${WCRS_FRONTEND_HOME}/${RELEASE_DIR}/config/environments/development.rb"

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
echo "Running tests."
rake db:test:prepare
xvfb-run cucumber -f json -o ${WCRS_FRONTEND_HOME}/live/features/reports/cucumber.json

exit 0


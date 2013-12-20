// Execute this script (from the Mongo shell) to reset the MongoDB registration user accounts database.
// WARNING - THIS SCRIPT DELETES THE CONTENTS OF THE DATABASE !!!
//
// To execute (from the project's root directory):
// $ mongo waste-carrier-users -u mongoUser db/reset_registrations-users.js -p
//


db.users.remove();
db.agency_users.remove();
db.admins.remove();



// Execute this script (from the Mongo shell) to reset the MongoDB registrations database.
// WARNING - THIS SCRIPT DELETES THE CONTENTS OF THE DATABASE !!!
//
// To execute (from the project's root directory):
// $ mongo waste-carriers -u mongoUser db/reset_registrations.js -p
//

//console.log("Deleting registrations...");
db.registrations.remove();
//console.log("Deleted all registrations.");

//console.log("Resetting the registration number counter.");
db.counters.remove();
//console.log("The registration number counter has been reset.");


//By now there should be no records/documents in the registrations collection

//console.log("db.registrations.count() = " + db.registrations.count());

//...and the counter - as used for registration numbers - should have been reset.
//The next insert will re-create the one record in the counters collection.

//console.log("db.counters.count() = " + db.counters.count());

//console.log("THE END - The registrations database has been reset.");


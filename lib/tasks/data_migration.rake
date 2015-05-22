namespace :data_migration do

  # Adds a "tier" field to all existing registrations, setting the value to
  # "LOWER" if the field does not already exist.
  # This replaces the functionality of the
  # waste-exemplar-services/bin/migrate_phase_1.js script.
  task :lower_tier => :environment do |t|
    puts '*** Waste Carriers Data Migration Script ***'

    puts 'Number of registrations in the database: '
    send_mongo_command 'db.registrations.count()'

    puts 'About to update - adding "tier" property...'
    send_mongo_command 'db.registrations.update( '\
      "{ 'tier': { $exists: false } }, "\
      "{ $set: { 'tier': 'LOWER' } }, { multi: true } )"

    puts 'About to update - converting dateRegistered to Date...'
    send_mongo_command 'db.registrations'\
      ".find({ 'metaData.dateRegistered': { $exists: true } })"\
      '.forEach(
        function(element){
          element.metaData.dateRegistered = new Date(element.metaData.dateRegistered);
          db.registrations.save(element);
        }
      )'

    puts 'About to update - converting dateActivated to Date...'
    send_mongo_command 'db.registrations'\
      ".find({'metaData.dateActivated': { $exists: true } })"\
      '.forEach(
        function(element){
          element.metaData.dateActivated = new Date(element.metaData.dateActivated);
          db.registrations.save(element);
        }
      )'

    puts 'About to update - converting lastModified to Date....'
    send_mongo_command 'db.registrations'\
      ".find({'metaData.lastModified': { $exists: true } })"\
      '.forEach(
        function(element){
          element.metaData.lastModified = new Date(element.metaData.lastModified);
          db.registrations.save(element);
        }
      )'
    puts 'Update completed.'
  end


  task :migrate_address_model => :environment do |t|

    puts 'Number of registrations in the database: '
    send_mongo_command 'db.registrations.count()'

    puts 'About to update - converting to new address model...'
    send_mongo_command 'db.registrations.find().forEach(
    function(element){
     db.registrations.update({_id: element._id},{$set: { "addresses": [{"uprn": element.uprn, "addressType": "REGISTERED",
      "addressMode": element.addressMode, "houseNumber": element.houseNumber,
      "addressLine1": element.streetLine1, "addressLine2": element.streetLine2,
      "addressLine3": element.streetLine3, "addressLine4": element.streetLine4,
      "townCity": element.townCity, "postcode": element.postcode,
      "country": element.country, "dependentLocality": element.dependentLocality,
      "dependentThoroughfare": element.dependendThoroughfare, "administrativeArea": element.administrativeArea,
      "localAuthorityUpdateDate": element.localAuthorityUpdateDate, "royalMailUpdateDate": element.royalMailUpdateDate,
      "easting": element.easting, "northing": element.northing, "location.lat": element.location.lat,
      "location.lon": element.location.lon}]}});})
    db.registrations.find().forEach(
    function(element){
      if(element.addresses[0].uprn == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.uprn": ""}});};
      if(element.addresses[0].addressMode == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.addressMode": ""}});};
      if(element.addresses[0].houseNumber == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.houseNumber": ""}});};
      if(element.addresses[0].addressLine1 == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.addressLine1": ""}});};
      if(element.addresses[0].addressLine2 == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.addressLine2": ""}});};
      if(element.addresses[0].addressLine3 == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.addressLine3": ""}});};
      if(element.addresses[0].addressLine4 == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.addressLine4": ""}});};
      if(element.addresses[0].townCity == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.townCity": ""}});};
      if(element.addresses[0].postcode == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.postcode": ""}});};
      if(element.addresses[0].country == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.country": ""}});};
      if(element.addresses[0].dependentLocality == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.dependentLocality": ""}});};
      if(element.addresses[0].dependentThoroughfare == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.dependentThoroughfare": ""}});};
      if(element.addresses[0].administrativeArea == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.administrativeArea": ""}});};
      if(element.addresses[0].localAuthorityUpdateDate == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.localAuthorityUpdateDate": ""}});};
      if(element.addresses[0].royal_mail_update_date == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.royalMailUpdateDate": ""}});};
      if(element.addresses[0].easting == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.easting": ""}});};
      if(element.addresses[0].northing == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.northing": ""}});};
      if(element.addresses[0].location.lat == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.location.lat": ""}});};
      if(element.addresses[0].location.lon == undefined) {
        db.registrations.update({_id: element._id},{$unset: {"addresses.0.location.lon": ""}});};})'

    puts 'Update completed.'
  end

  def send_mongo_command(command)
    host = ENV['WCRS_REGSDB_URL1']
    throw 'MongoDB host URL not available' if host.nil?
    database = ENV['WCRS_REGSDB_NAME']
    throw 'MongoDB database name not available' if database.nil?
    username = ENV['WCRS_REGSDB_USERNAME']
    throw 'MongoDB username not available' if username.nil?
    password = ENV['WCRS_REGSDB_PASSWORD']
    throw 'MongoDB password not avaialble' if password.nil?

    puts 'Sending command to mongo. This may take some time and progress '\
      "won't be displayed so please be patient..."
    result = system(
      'mongo',
      "#{host}/#{database}",
      '-u',
      username,
      '-p',
      password,
      '--quiet',
      '--eval',
      command)
    throw "send_mongo_command failed: #{command}" unless result == true
  end

end

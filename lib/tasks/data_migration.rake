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

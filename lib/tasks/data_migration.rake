namespace :data_migration do
  
  # Adds a "tier" field to all existing registrations, setting the value to "LOWER" if the field does not already exist.
  # This replaces the functionality of the waste-exemplar-services/bin/migrate_phase_1.js script.
  task :lower_tier => :environment do |t|
    puts '*** Waste Carriers Data Migration Script ***'
    
    host = ENV['WCRS_FRONTEND_USERSDB_URL']
    throw 'MongoDB host URL not available' unless host != nil
    database = ENV['WCRS_FRONTEND_USERSDB_NAME']
    throw 'MongoDB database name not available' unless database != nil
    username = ENV['WCRS_FRONTEND_USERSDB_USERNAME']
    throw 'MongoDB username not available' unless username != nil
    password = ENV['WCRS_FRONTEND_USERSDB_PASSWORD']
    throw 'MongoDB password not avaialble' unless password != nil
    
    databaseURL = "#{host}/#{database}"
    puts "Will perform migration on database #{databaseURL}"
    
    puts 'Number of registrations in the database: '
    result = system('mongo', databaseURL, '-u', username, '-p', password, '--quiet', '--eval', 'db.registrations.count()')
    throw '!! Count query failed, aborting migration task !!' unless result == true
    
    puts 'About to update - adding "tier" property...'
    result = system('mongo', databaseURL, '-u', username, '-p', password, '--quiet', '--eval', "db.registrations.update({'tier':{$exists:false}},{$set:{'tier':'LOWER'}},{multi:true})")
    throw '!! Migration query failed, manual investigation required !!' unless result == true
    
    puts 'Update completed.'
  end
  
end

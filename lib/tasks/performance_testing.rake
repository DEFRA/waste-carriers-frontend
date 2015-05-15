require 'faker'
require "#{Rails.root}/features/support/data_creation.rb"
require "ruby-progressbar"

namespace :performance_testing do
  @counties = ['Avon', 'Bedfordshire', 'Berkshire', 'Buckinghamshire', 'Cambridgeshire', 'Cheshire', 'Cornwall', 'Cumbria', 'Derbyshire', 'Devon', 'Dorset', 'Durham', 'East Sussex', 'Essex', 'Gloucestershire', 'Greater Manchester', 'Hampshire', 'Herefordshire', 'Hertfordshire', 'Humberside', 'Isle of Wight', 'Kent', 'Lancashire', 'Leicestershire', 'Lincolnshire', 'Merseyside', 'Norfolk', 'North Yorkshire', 'Northamptonshire', 'Northumberland', 'Nottinghamshire', 'Oxfordshire', 'Shropshire', 'Somerset', 'South Yorkshire', 'Staffordshire', 'Suffolk', 'Surrey', 'Tyne and Wear', 'Warwickshire', 'West Midlands', 'West Sussex', 'West Yorkshire', 'Wiltshire', 'Worcestershire']

  def make_company_name
    service = ['waste', 'disposal', 'demolition', 'recycling', 'removal', 'reclamation', 'reprocessing', 'clearance', 'scrappage', 'junk'].sample
    suffix = ['LTD', 'services', 'company', 'contractors', 'limitted', 'industrial services', 'group'].sample
    if rand < 0.2
      county = @counties.sample
      return "#{county} #{service} #{suffix}"
    else
      name1 = Faker::Name::last_name
      if rand < 0.5
        return "#{name1} #{service} #{suffix}"
      else
        name2 = Faker::Name::last_name
        return "#{name1} & #{name2} #{service} #{suffix}"
      end
    end
  end

  def make_company_number
    (1 + rand(999_999_98)).to_s.rjust(8, '0')
  end

  def make_random_postcode
    a1 = (65 + rand(26)).chr
    a2 = (65 + rand(26)).chr
    n1 = rand(1..15).to_s
    n2 = rand(1..9).to_s
    a3 = (65 + rand(26)).chr
    a4 = (65 + rand(26)).chr
    "#{a1}#{a2}#{n1} #{n2}#{a3}#{a4}"
  end

  def randomise_lower_tier_reg_data(reg_data)
    reg_data['firstName'] = Faker::Name::first_name
    reg_data['lastName'] = Faker::Name::last_name
    reg_data['contactEmail'] = reg_data['accountEmail'] = "#{reg_data['firstName']}.#{reg_data['lastName']}" + rand(9999).to_s + "@example.com".downcase
    reg_data['password'] = Faker::Internet::password
    reg_data['phoneNumber'] = "01" + rand(999999999).to_s.rjust(9, '0')
    reg_data['companyName'] = make_company_name()

    address = reg_data['addresses'].find { |address| address.addressType == 'REGISTERED' }

    address['location'][0]['easting'] =  (200000 + rand(200000)).to_s
    address['location'][0]['northing'] = (100000 + rand(400000)).to_s
    address['uprn'] =     (100000 + rand(400000)).to_s
    address['houseNumber'] = (1 + rand(300)).to_s
    address['addressLine1'] = Faker::Address::street_name
    address['townCity'] = Faker::Address::city
    address['administrativeArea'] = @counties.sample
    address['postcode'] = make_random_postcode()

    reg_data
  end

  def randomise_upper_tier_reg_data(reg_data)
    randomise_lower_tier_reg_data(reg_data)
    reg_data['company_no'] = make_company_number()
    reg_data['key_people'][0]['first_name'] = reg_data['firstName']
    reg_data['key_people'][0]['last_name'] = reg_data['lastName']
    reg_data['key_people'][0]['dob'] = Faker::Date.between(70.years.ago, 20.years.ago).strftime('%F')

    reg_data
  end

  def make_random_ref_num
    #define the middle group of characters eg. AE8437YD
    @mid_group = ''
    while @mid_group.length < 8 do
      if @mid_group.length > 2 and @mid_group.length < 6
        @mid_group += rand(9).to_s
      else
        @mid_group += (65 + rand(26)).chr
      end
    end
    #define the end group eg. R034
    @end_group = (65 + rand(26)).chr
    while @end_group.length < 4 do
      @end_group += rand(9).to_s
    end

    "CB/#{@mid_group}/#{@end_group}"
  end

  def randomise_ir_renewal_data(renewal_type)
    ir_data = Irrenewal.create
    ir_data.applicantType = renewal_type
    ir_data.expiryDate = Faker::Date.between(2.months.from_now, 3.years.from_now).strftime('%F')
    ir_data.referenceNumber = make_random_ref_num
    registration_types = ['Carrier', 'Carrier and Broker']
    ir_data.registrationType = registration_types[rand(1)]
    if ir_data.applicantType == 'Company'
      ir_data.irType = 'COMPANY'
    elsif ir_data.applicantType == 'Person'
      ir_data.irType = 'INDIVIDUAL'
    elsif ir_data.applicantType== 'Organisation of Individuals'
      ir_data.irType = 'PARTNER'
    elsif ir_data.applicantType == 'Public Body'
      ir_data.irType = 'PUBLIC_BODY'
    end
    company_names = ['', Faker::Company::name + ' ' + Faker::Commerce.department(2, true)]
    ir_data.companyName = company_names[rand(2)]
    trading_names = ['', Faker::Company::name, ir_data.companyName]
    ir_data.tradingName = trading_names[rand(2)]
    company_number = '07'
    while company_number.length < 8 do
      company_number += rand(9).to_s
    end
    company_numbers = ['', company_number]
    ir_data.companyNumber = company_numbers[rand(2)]
    ir_data.trueRegistrationType = ir_data.registrationType.upcase
    permit_holder_names = ['', Faker::Name::first_name + ' ' + Faker::Name::last_name]
    ir_data.permitHolderName = permit_holder_names[rand(2)]
    dobs = ['', Faker::Date.between(70.years.ago, 20.years.ago).strftime('%F')]
    ir_data.dateOfBirth = dobs[rand(1)]
    party_sub_types = ['', 'Partnership']
    ir_data.partySubType = party_sub_types[rand(2)]
    partnership_names = ['', Faker::Name::first_name + ' ' + Faker::Name::last_name]
    ir_data.partnershipName = partnership_names[rand(2)]
    party_names = ['', Faker::Name::first_name + ' ' + Faker::Name::last_name]
    ir_data.partyName = party_names[rand(2)]
    ir_data.save!
  end

  def create_phase_one_lower_tier_registration(recId)
    reg = PhaseOneRegistration.new

    reg.phase_one_registration_info = PhaseOneRegistrationInfo.new
    reg.phase_one_location = PhaseOneLocation.new

    randomise_phase_one_lower_tier_registration(reg, recId)

    reg.phase_one_registration_info.status = 'ACTIVE'
    reg.phase_one_registration_info.dateActivated =
      reg.phase_one_registration_info.lastModified

    reg.save

    reg
  end

  def randomise_phase_one_lower_tier_registration(reg, recId)
    regDate = Faker::Time.between(DateTime.new(2014,1,1), 6.months.ago)
    lastModDate = recId.odd? ? regDate : Faker::Time.between(regDate + 1.hour, 6.months.ago)

    reg.uuid = SecureRandom.uuid
    reg.businessType = 'soleTrader'
    reg.companyName = Faker::Company::name
    reg.streetLine1 = Faker::Address::street_name
    reg.streetLine2 = Faker::Address::street_address
    reg.townCity = Faker::Address::city
    reg.postcode = make_random_postcode()
    reg.easting = (200000 + rand(200000)).to_s
    reg.northing = (100000 + rand(400000)).to_s
    reg.dependentLocality = ''
    reg.dependentThroughfare = ''
    reg.administrativeArea = @counties.sample
    reg.localAuthorityUpdateDate = ''
    reg.royalMailUpdateDate = ''
    reg.uprn = rand(999999999).to_s.rjust(12, '0')
    reg.title = 'Mr'
    reg.otherTitle = ''
    reg.firstName = Faker::Name::first_name
    reg.lastName = Faker::Name::last_name
    reg.position = Faker::Name::title
    reg.phoneNumber = '01' + rand(999999999).to_s.rjust(9, '0')
    reg.contactEmail = "#{reg.firstName}.#{reg.lastName}#{rand(9999)}"\
      '@example.com'.downcase
    reg.accountEmail = reg.contactEmail
    reg.declaration = '1'
    reg.regIdentifier = 'CBDL' + recId.to_s

    reg.phase_one_registration_info.dateRegistered = regDate.strftime('%Y/%m/%d %H:%M:%S')
    reg.phase_one_registration_info.anotherString = 'userDetailAddedAtRegistration'
    reg.phase_one_registration_info.lastModified = lastModDate.strftime('%Y/%m/%d %H:%M:%S')
    reg.phase_one_registration_info.route = 'DIGITAL'
    reg.phase_one_registration_info.distance = 'n/a'

    reg.phase_one_location.lat = Faker::Address::latitude
    reg.phase_one_location.lon = Faker::Address::longitude
  end

  task :seed_lower_tier_registrations, [:num_records] => :environment do |t, args|
    args.with_defaults(:num_records => 10)
    puts "Creating #{args.num_records} complete lower-tier registrations..."
    pb = ProgressBar.create(total: args.num_records.to_i, throttle_rate: 0.1, format: '%E |%b>%i| %p%%')
    reg_data = JSON.parse(File.read('features/fixtures/LTD_LT_online_complete.json')).except('selectedAddress')
    for n in (1..args.num_records.to_i) do
      create_complete_lower_tier_reg_from_hash(randomise_lower_tier_reg_data(reg_data))
      pb.increment
    end
  end

  task :seed_upper_tier_registrations, [:num_records] => :environment do |t, args|
    args.with_defaults(:num_records => 10)
    puts "Creating #{args.num_records} complete upper-tier registrations..."
    pb = ProgressBar.create(total: args.num_records.to_i, throttle_rate: 0.1, format: '%E |%b>%i| %p%%')
    reg_data = JSON.parse(File.read('features/fixtures/LTD_UT_online_complete.json')).except('selectedAddress')
    for n in (1..args.num_records.to_i) do
      create_complete_upper_tier_reg_from_hash(randomise_upper_tier_reg_data(reg_data), 'Bank Transfer', 0)
      pb.increment
    end
  end

  task :seed_convictions, [:num_records] => :environment do |t, args|
    args.with_defaults(:num_records => 10)
    puts "Creating #{args.num_records} conviction records..."
    pb = ProgressBar.create(total: args.num_records.to_i, throttle_rate: 0.1, format: '%E |%b>%i| %p%%')

    # Configure the ElasticSearch client connection.
    Conviction.gateway.client = Elasticsearch::Client.new host: Rails.configuration.waste_exemplar_elasticsearch_url

    # Generate a mixture of company and individual conviction records.
    system_flag_names = ['EMS', 'NEDS']
    for n in (1..args.num_records.to_i) do
      incident_number = (1000 + rand(99999)).to_s
      # We'll make one-fifth of the records for individuals, the rest for companies...
      if (n.modulo(5) == 0)
        person_name = Faker::Name::first_name + " " + Faker::Name::last_name
        # And we'll make about 20% of individuals have no known date-of-birth.
        if (rand < 0.2)
          Conviction.create name: person_name, systemFlag: system_flag_names.sample, incidentNumber: incident_number
        else
          Conviction.create name: person_name, systemFlag: system_flag_names.sample, incidentNumber: incident_number, dateOfBirth: Faker::Date.between(70.years.ago, 20.years.ago)
        end
      else
        Conviction.create name: make_company_name(), companyNumber: make_company_number(), systemFlag: system_flag_names.sample, incidentNumber: incident_number
      end
      pb.increment
    end
  end

  task :seed_ir_renewals, [:num_records] => :environment do |t, args|
    args.with_defaults(:num_records => 10)
    puts "Creating #{args.num_records} complete IR-renewals..."
    pb = ProgressBar.create(total: args.num_records.to_i, throttle_rate: 0.1, format: '%E |%b>%i| %p%%')
    for n in (1..args.num_records.to_i) do
      randomise_ir_renewal_data('Person')
      randomise_ir_renewal_data('Company')
      randomise_ir_renewal_data('Organisation of Individuals')
      randomise_ir_renewal_data('Public Body')
      pb.increment
    end
  end

  task :seed_phase_one_lower_tier_registrations, [:num_records] => :environment do |t, args|
    args.with_defaults(num_records: 10)

    max_recs = args.num_records.to_i

    pb = ProgressBar.create(
      total: max_recs,
      throttle_rate: 0.1,
      format: '%E |%b>%i| %p%%'
    )

    puts "Creating #{max_recs} phase one registrations..."
    for n in (1..max_recs) do
      reg = create_phase_one_lower_tier_registration n
      create_user(reg.accountEmail)
      pb.increment
    end

    send_mongo_command('db.registrations.update({}, '\
      "{ $unset: { 'metaData._id': 1 } }, false, true)")
    send_mongo_command('db.registrations.update({},'\
      "{ $unset: { 'location._id': 1 } }, false, true)")
  end
end

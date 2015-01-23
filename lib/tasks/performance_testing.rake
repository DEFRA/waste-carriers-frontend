require 'faker'
require "#{Rails.root}/features/support/data_creation.rb"

namespace :performance_testing do
  @counties = ['Avon', 'Bedfordshire', 'Berkshire', 'Buckinghamshire', 'Cambridgeshire', 'Cheshire', 'Cornwall', 'Cumbria', 'Derbyshire', 'Devon', 'Dorset', 'Durham', 'East Sussex', 'Essex', 'Gloucestershire', 'Greater Manchester', 'Hampshire', 'Herefordshire', 'Hertfordshire', 'Humberside', 'Isle of Wight', 'Kent', 'Lancashire', 'Leicestershire', 'Lincolnshire', 'Merseyside', 'Norfolk', 'North Yorkshire', 'Northamptonshire', 'Northumberland', 'Nottinghamshire', 'Oxfordshire', 'Shropshire', 'Somerset', 'South Yorkshire', 'Staffordshire', 'Suffolk', 'Surrey', 'Tyne and Wear', 'Warwickshire', 'West Midlands', 'West Sussex', 'West Yorkshire', 'Wiltshire', 'Worcestershire']

  def make_company_name
    service = ['waste', 'disposal', 'demolition', 'recycling', 'removal', 'reclamation', 'reprocessing', 'clearance', 'scrappage', 'junk'].sample
    suffix = ['LTD', 'services', 'company', 'contractors', 'limitted', 'industrial services', 'group'].sample
    if (rand < 0.2)
      county = @counties.sample
      return "#{county} #{service} #{suffix}"
    else
      name1 = Faker::Name::last_name
      if (rand < 0.5)
        return "#{name1} #{service} #{suffix}"
      else
        name2 = Faker::Name::last_name
        return "#{name1} & #{name2} #{service} #{suffix}"
      end
    end
  end

  def make_company_number
    return (1 + rand(99999998)).to_s.rjust(8, '0')
  end

  def make_random_postcode
    a1 = (65 + rand(26)).chr
    a2 = (65 + rand(26)).chr
    n1 = rand(1..15).to_s
    n2 = rand(1..9).to_s
    a3 = (65 + rand(26)).chr
    a4 = (65 + rand(26)).chr
    return "#{a1}#{a2}#{n1} #{n2}#{a3}#{a4}"
  end

  def randomise_lower_tier_reg_data(reg_data)
    reg_data['firstName'] = Faker::Name::first_name
    reg_data['lastName'] = Faker::Name::last_name
    reg_data['contactEmail'] = reg_data['accountEmail'] = "#{reg_data['firstName']}.#{reg_data['lastName']}" + rand(9999).to_s + "@example.com"
    reg_data['password'] = Faker::Internet::password
    reg_data['phoneNumber'] = "01" + rand(999999999).to_s.rjust(9, '0')
    reg_data['easting'] =  (200000 + rand(200000)).to_s
    reg_data['northing'] = (100000 + rand(400000)).to_s
    reg_data['uprn'] =     (100000 + rand(400000)).to_s
    reg_data['companyName'] = make_company_name()
    reg_data['houseNumber'] = (1 + rand(300)).to_s
    reg_data['streetLine1'] = Faker::Address::street_name
    reg_data['townCity'] = Faker::Address::city
    reg_data['administrativeArea'] = @counties.sample
    reg_data['postcode'] = make_random_postcode()
    return reg_data
  end

  def randomise_upper_tier_reg_data(reg_data)
    randomise_lower_tier_reg_data(reg_data)
    reg_data['company_no'] = make_company_number()
    reg_data['key_people'][0]['first_name'] = reg_data['firstName']
    reg_data['key_people'][0]['last_name'] = reg_data['lastName']
    reg_data['key_people'][0]['dob'] = Faker::Date.between(70.years.ago, 20.years.ago).strftime('%F')
    return reg_data
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

    return "CB/#{@mid_group}/#{@end_group}"
  end

  def randomise_ir_renewal_data
    ir_data = Irrenewal.create
    applicant_types = ['Person', 'Company', 'Organisation of Individuals', 'Public Body']
    ir_data.applicant_type = applicant_types[rand(4)]
    ir_data.expiry_date = Faker::Date.between(2.months.from_now, 3.years.from_now).strftime('%F')
    ir_data.reference_number = make_random_ref_num
    registration_types = ['Carrier', 'Carrier and Broker']
    ir_data.registration_type = registration_types[rand(1)]
    if ir_data.applicant_type == 'Company'
      ir_data.ir_type = 'COMPANY'
    elsif ir_data.applicant_type == 'Person'
      ir_data.ir_type = 'INDIVIDUAL'
    elsif ir_data.applicant_type== 'Organisation of Individuals'
      ir_data.ir_type = 'PARTNER'
    elsif ir_data.applicant_type == 'Public Body'
      ir_data.ir_type = 'PUBLIC_BODY'
    end
    company_names = ['', Faker::Company::name + ' ' + Faker::Commerce.department(2, true)]
    ir_data.company_name = company_names[rand(1)]
    trading_names = ['', Faker::Company::name, ir_data.company_name]
    ir_data.trading_name = trading_names[rand(2)]
    company_number = '07'
    while company_number.length < 8 do
      company_number += rand(9).to_s
    end
    company_numbers = ['', company_number]
    ir_data.company_number = company_numbers[rand(1)]
    ir_data.true_registration_type = ir_data.registration_type.upcase
    permit_holder_names = ['', Faker::Name::first_name + ' ' + Faker::Name::last_name]
    ir_data.permit_holder_name = permit_holder_names[rand(1)]
    dobs = ['', Faker::Date.between(70.years.ago, 20.years.ago).strftime('%F')]
    ir_data.dob = dobs[rand(1)]
    party_sub_types = ['', 'Partnership']
    ir_data.party_sub_type = party_sub_types[rand(1)]
    partnership_names = ['', Faker::Name::first_name + ' ' + Faker::Name::last_name]
    ir_data.partnership_name = partnership_names[rand(1)]
    party_names = ['', Faker::Name::first_name + ' ' + Faker::Name::last_name]
    ir_data.party_name = party_names[rand(1)]
    ir_data.save!
  end

  task :seed_lower_tier_registrations, [:num_records] => :environment do |t, args|
    args.with_defaults(:num_records => 10)
    puts "Creating #{args.num_records} complete lower-tier registrations..."
    reg_data = JSON.parse(File.read('features/fixtures/LTD_LT_online_complete.json')).except('selectedAddress')
    for n in (1..args.num_records.to_i) do
      create_complete_lower_tier_reg_from_hash(randomise_lower_tier_reg_data(reg_data))
    end
  end

  task :seed_upper_tier_registrations, [:num_records] => :environment do |t, args|
    args.with_defaults(:num_records => 10)
    puts "Creating #{args.num_records} complete upper-tier registrations..."
    reg_data = JSON.parse(File.read('features/fixtures/LTD_UT_online_complete.json')).except('selectedAddress')
    for n in (1..args.num_records.to_i) do
      create_complete_upper_tier_reg_from_hash(randomise_upper_tier_reg_data(reg_data), 'Bank Transfer', 0)
    end
  end

  task :seed_convictions, [:num_records] => :environment do |t, args|
    args.with_defaults(:num_records => 10)
    puts "Creating #{args.num_records} conviction records..."

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
    end
  end

  task :seed_irrenewals, [:num_records] => :environment do |t, args|
    args.with_defaults(:num_records => 10)
    puts "Creating #{args.num_records} complete IR-renewals..."
    for n in (1..args.num_records.to_i) do
      randomise_ir_renewal_data
    end
  end

end

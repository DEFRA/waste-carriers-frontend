require 'Faker'
require "#{Rails.root}/features/support/data_creation.rb"

namespace :stress_data do
  @counties = ['Avon', 'Bedfordshire', 'Berkshire', 'Buckinghamshire', 'Cambridgeshire', 'Cheshire', 'Cornwall', 'Cumbria', 'Derbyshire', 'Devon', 'Dorset', 'Durham', 'East Sussex', 'Essex', 'Gloucestershire', 'Greater Manchester', 'Hampshire', 'Herefordshire', 'Hertfordshire', 'Humberside', 'Isle of Wight', 'Kent', 'Lancashire', 'Leicestershire', 'Lincolnshire', 'Merseyside', 'Norfolk', 'North Yorkshire', 'Northamptonshire', 'Northumberland', 'Nottinghamshire', 'Oxfordshire', 'Shropshire', 'Somerset', 'South Yorkshire', 'Staffordshire', 'Suffolk', 'Surrey', 'Tyne and Wear', 'Warwickshire', 'West Midlands', 'West Sussex', 'West Yorkshire', 'Wiltshire', 'Worcestershire']
  
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
    reg_data['companyName'] = Faker::Company::name + " " + Faker::Commerce.department(2, true)
    reg_data['houseNumber'] = (1 + rand(300)).to_s
    reg_data['streetLine1'] = Faker::Address::street_name
    reg_data['townCity'] = Faker::Address::city
    reg_data['administrativeArea'] = @counties[rand(@counties.length)]
    reg_data['postcode'] = make_random_postcode()
    return reg_data
  end
  
  def randomise_upper_tier_reg_data(reg_data)
    randomise_lower_tier_reg_data(reg_data)
    reg_data['company_no'] = rand(99999999).to_s.rjust(8, '0')
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

  def randomise_ir_renewal_data(ir_data)
    @applicantTypes = ['Person', 'Company', 'Organisation of Individuals', 'Public Body']
    ir_data['applicantType'] = @applicantTypes[rand(4)]
    ir_data['expiryDate'] = Faker::Date.between(2.months.from_now, 3.years.from_now).strftime('%F')
    ir_data['referenceNumber'] = make_random_ref_num
    @registrationTypes = ['Carrier', 'Carrier and Broker']
    ir_data['registrationType'] = @registrationTypes[rand(1)]
    if ir_data['applicantType'] == 'Company'
      ir_data['irType'] = 'COMPANY'
    elsif ir_data['applicantType'] == 'Person'
      ir_data['irType'] = 'INDIVIDUAL'
    elsif ir_data['applicantType'] == 'Organisation of Individuals'
      ir_data['irType'] = 'PARTNER'
    elsif ir_data['applicantType'] == 'Public Body'
      ir_data['irType'] = 'PUBLIC_BODY'
    end
    @companyNames = ['', Faker::Company::name + ' ' + Faker::Commerce.department(2, true)]
    ir_data['companyName'] = @companyNames[rand(1)]
    @tradingNames = ['', Faker::Company::name, ir_data['companyName']]
    ir_data['tradingName'] = @tradingNames[rand(2)]
    @companyNumber = '07'
    while @companyNumber.length < 8 do
      @companyNumber += rand(9).to_s
    end
    @companyNumbers = ['', @companyNumber]
    ir_data['companyNumber'] = @companyNumbers[rand(1)]
    ir_data['trueRegistrationType'] = ir_data['registrationType'].upcase
    @permitHolderNames = ['', Faker::Name::first_name + ' ' + Faker::Name::last_name]
    ir_data['permitHolderName'] = @permitHolderNames[rand(1)]
    @datesOfBirth = ['', Faker::Date.between(70.years.ago, 20.years.ago).strftime('%F')]
    ir_data['dateOfBirth'] = @datesOfBirth[rand(1)]
    @partySubTypes = ['', 'Partnership']
    ir_data['partySubType'] = @partySubTypes[rand(1)]
    @partnershipNames = ['', Faker::Name::first_name + ' ' + Faker::Name::last_name]
    ir_data['partnershipName'] = @partnershipNames[rand(1)]
    @partyNames = ['', Faker::Name::first_name + ' ' + Faker::Name::last_name]
    ir_data['partyName'] = @partyNames[rand(1)]

  end
  
  task :seed_lower_tier, [:num_records] => :environment do |t, args|
    args.with_defaults(:num_records => 10)
    puts "Creating #{args.num_records} complete lower-tier registrations..."
    reg_data = JSON.parse(File.read('features/fixtures/LTD_LT_online_complete.json')).except('selectedAddress')
    for n in (1..args.num_records.to_i) do
      create_complete_lower_tier_reg_from_hash(randomise_lower_tier_reg_data(reg_data))
    end
  end
  
  task :seed_upper_tier, [:num_records] => :environment do |t, args|
    args.with_defaults(:num_records => 10)
    puts "Creating #{args.num_records} complete upper-tier registrations..."
    reg_data = JSON.parse(File.read('features/fixtures/LTD_UT_online_complete.json')).except('selectedAddress')
    for n in (1..args.num_records.to_i) do
      create_complete_upper_tier_reg_from_hash(randomise_upper_tier_reg_data(reg_data), 'Bank Transfer', 0)
    end
  end

  task :seed_irrenewals, [:num_records] => :environment do |t, args|
    args.with_defaults(:num_records => 10)
    puts "Creating #{args.num_records} complete IR-renewals..."
    irdata = {
                applicantType: '',
                expiryDate: '',
                referenceNumber: '',
                registrationType: '',
                irType: '',
                companyName: '',
                tradingName: '',
                companyNumber: '',
                trueRegistrationType: '',
                permitHolderName: '',
                dateOfBirth: '',
                partySubType: '',
                partnershipName: '',
                partyName: ''
              }
    for n in (1..args.num_records.to_i) do
      randomise_ir_renewal_data(ir_data)
    end
  end

end

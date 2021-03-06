FactoryGirl.define do
  factory :irrenewal do

    Faker::Config.locale = 'en-GB'

    sequence(:id) { |n| n }

    expiryDate Date.today + 1.week
    referenceNumber 'CB/VM1111WW/A001'
    registrationType 'Carrier and Broker'
    trueRegistrationType 'CARRIER_AND_BROKER'

    trait :company do
      applicantType 'Company'
      irType 'COMPANY'
      companyName Faker::Company.name
      tradingName ''
      companyNumber '07713745'
    end

    trait :partnership do
      applicantType 'Organisation of Individuals'
      irType 'PARTNER'
      partySubType 'Grades and Gravel partnership'
      partnershipName Faker::Name.name
      dateOfBirth Date.parse('1959-04-23')
    end

    trait :individual do
      applicantType 'Person'
      irType 'INDIVIDUAL'
      permitHolderName Faker::Name.name
      tradingName "#{Faker::Name.first_name}'s Bits'"
      dateOfBirth Date.parse('1979-08-15')
    end

    trait :public_body do
      applicantType 'Public Body'
      irType 'PUBLIC_BODY'
      partyName "#{Faker::Address.county} City Council"
      tradingName "#{Faker::Address.county} City Council"
    end

    trait :expired do
      expiryDate Date.today
    end

    trait :expires_outside_renewal_window do
      expiryDate (Rails.configuration.registration_renewal_window + 1.month).from_now
    end

    trait :already_renewed do
      referenceNumber 'CB/RN5419MF/R002'
    end

    trait :being_renewed do
      referenceNumber 'CB/RN5572WE/R002'
    end

  end
end

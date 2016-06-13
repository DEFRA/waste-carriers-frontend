FactoryGirl.define do
  factory :registration do

    sequence(:id) { |n| n }
    title 'Mr'
    firstName 'John'
    lastName 'Testing'
    contactEmail 'john@example.com'
    businessType 'limitedCompany'
    company_no '012345678'
    registrationType 'carrier_broker_dealer'
    tier 'UPPER'
    newOrRenew ''

    trait :partnership do
      businessType 'partnership'
    end

    trait :sole_trader do
      businessType 'soleTrader'
    end

    trait :ir_renewal do
      originalRegistrationNumber 'CB/VM1111WW/A001'
      originalDateExpiry Date.today + 1.week
      newOrRenew 'renew'
    end

    trait :creating do
      newOrRenew 'new'
    end

    trait :editing do
      uuid '57441b720cf2edaa97355a4d'
      newOrRenew nil
    end

    after(:build) do |registration|
      registration.addresses << Address.init(attributes_for(:address, addressType: 'POSTAL'))
      registration.addresses << Address.init(attributes_for(:address, addressType: 'REGISTERED'))
    end

  end
end

FactoryGirl.define do
  factory :address do

    Faker::Config.locale = 'en-GB'

    sequence(:id) { |n| n }
    uprn 'string'
    addressType 'POSTAL'
    addressMode 'string'
    houseNumber Faker::Address.building_number
    addressLine1 Faker::Address.street_name
    addressLine2 'string'
    addressLine3 'string'
    addressLine4 'string'
    townCity 'string'
    postcode Faker::Address.postcode
    country 'string'
    dependentLocality 'string'
    dependentThoroughfare 'string'
    administrativeArea 'string'
    localAuthorityUpdateDate 'string'
    royalMailUpdateDate 'string'
    easting 'string'
    northing 'string'
    firstName 'string'
    lastName 'string'

  end
end

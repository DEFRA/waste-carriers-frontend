FactoryGirl.define do
  factory :irrenewal do

    sequence(:id) { |n| n }
    applicantType 'string'
    expiryDate 'string'
    referenceNumber 'CB/VM1111WW/A001'
    registrationType 'string'
    irType 'string'
    companyName 'string'
    tradingName 'string'
    companyNumber 'string'
    trueRegistrationType 'string'
    permitHolderName 'string'
    dateOfBirth 'string'
    partySubType 'string'
    partnershipName 'string'
    partyName 'string'

  end
end

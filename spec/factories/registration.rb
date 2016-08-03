FactoryGirl.define do
  factory :registration do

    sequence(:id) { |n| n }
    title 'Mr'
    firstName 'John'
    lastName 'Testing'
    contactEmail 'john@example.com'
    businessType 'limitedCompany'
    company_no '012345678'
    companyName Faker::Company.name
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

    trait :with_finance_details do
      after(:build) do |registration|
        order_json = {
          "orderId": "1dd52eca-b177-46bd-8d38-9339d08b5d00",
          "dateCreated": "1417527485000",
          "totalAmount": "15900",
          "worldPayStatus": "AUTHORISED",
          "merchantId": "EASERRSIMECOM",
          "orderCode": "1417527485",
          "paymentMethod": "ONLINE",
          "updatedByUser": "wp@example.org",
          "dateLastUpdated": "2014-12-02T13:40:28Z",
          "currency": "GBP",
          "description": "New Waste Carrier Registration: CBDU11 for test, Plus 1 copy cards"
        }
        payment_json = {
          "amount": 0,
          "dateReceived_day": "11",
          "dateReceived_month": "11",
          "dateReceived_year": "1111",
          "registrationReference": "3334",
          "paymentType": "BANKTRANSFER",
          "comment": "eere",
          "dateReceived": "2015-11-11",
          "updatedByUser": "financebasic1@waste-exemplar.gov.uk",
          "orderKey": "1417379915",
          "currency": "GBP",
          "manualPayment": true,
          "dateEntered": "1417527485000"
        }
        finance_details_json = {
          orders: [order_json],
          payments: [payment_json]
        }
        registration.finance_details << FinanceDetails.init(finance_details_json)
      end
    end

  end
end

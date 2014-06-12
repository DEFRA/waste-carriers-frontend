Given(/^I am registering as a limited company$/) do
  visit find_path

  choose 'registration_businessType_limitedcompany'
  click_on 'Next'
end

Given(/^I am on the upper tier business details page$/) do
  choose 'registration_otherBusinesses_yes'
  click_on 'Next'

  choose 'registration_isMainService_yes'
  click_on 'Next'

  choose 'registration_onlyAMF_no'
  click_on 'Next'

  choose 'registration_registrationType_carrier_dealer'
  click_on 'Next'
end

And(/^I enter my company name and address$/) do
  fill_in 'registration_companyName', with: 'The Ladd Company'

  fill_in 'registration_streetLine1', with: 'Horizon House'
  fill_in 'registration_streetLine2', with: 'Deanery Street'
  fill_in 'registration_townCity', with: 'Bristol'
  fill_in 'registration_postcode', with: 'BS1 5AH'
end
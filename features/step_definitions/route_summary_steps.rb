Given(/^I have come to the lower tier summary page$/) do
  visit find_path

  choose 'registration_businessType_soletrader'
  click_on 'Next'

  choose 'registration_otherBusinesses_no'
  click_on 'Next'

  choose 'registration_constructionWaste_no'
  click_on 'Next'

  click_on 'I want to add an address myself'
  fill_in 'registration_companyName', with: 'Grades & Co'
  fill_in 'registration_houseNumber', with: '12'
  fill_in 'registration_streetLine1', with: 'Deanery Road'
  fill_in 'registration_streetLine2', with: 'EA Building'
  fill_in 'registration_townCity', with: 'Bristol'
  fill_in 'registration_postcode', with: 'BS1 5AH'
  click_on 'Next'

  fill_in 'First name', with: 'Joe'
  fill_in 'Last name', with: 'Bloggs'
  fill_in 'Job title', with: 'Chief Barber'
  fill_in 'Phone number', with: '0117 926 8332'
  fill_in 'Email address', with: my_email_address
  click_on 'Next'
end

Then(/^I see I am a lower tier waste carrier$/) do
  page.should have_content 'You are a lower tier'
end

Given(/^I have come to the upper tier summary page$/) do
  visit find_path

  choose 'registration_businessType_soletrader'
  click_on 'Next'
  choose 'registration_otherBusinesses_yes'
  click_on 'Next'
  choose 'registration_isMainService_yes'
  click_on 'Next'
  choose 'registration_onlyAMF_no'
  click_on 'Next'

  choose 'registration_registrationType_carrier_dealer'
  click_on 'Next'

  fill_in 'registration_companyName', with: 'Bespoke'
  fill_in 'sPostcode', with: 'BS1 5AH'
  click_on 'Find UK address'

  select 'Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH'
  click_on 'Next'

  fill_in 'First name', with: 'Joe'
  fill_in 'Last name', with: 'Bloggs'
  fill_in 'Job title', with: 'Chief Barber'
  fill_in 'Phone number', with: '0117 926 9999'
  fill_in 'Email address', with: my_email_address
  click_on 'Next'
end

Then(/^I see I am an upper tier waste carrier$/) do
  page.should have_content 'You are an upper tier'
end
Given(/^I have completed the upper tier and chosen to pay by bank transfer$/) do
  step 'I have been funneled into the upper tier path'
  step 'I am a carrier dealer'
  step 'I enter my business details'
  step 'I enter my contact details'
  step 'no key people in the organisation have convictions'
  step 'I confirm the declaration'
  step 'I enter new user account details'
  step 'I choose pay via electronic transfer'
end

Given(/^I have been funneled into the upper tier path$/) do
  visit find_path
  choose 'registration_businessType_soletrader'
  click_on 'Next'
  choose 'registration_otherBusinesses_yes'
  click_on 'Next'
  choose 'registration_isMainService_yes'
  click_on 'Next'
  choose 'registration_onlyAMF_no'
  click_on 'Next'
end

And(/^I am a carrier dealer$/) do
  choose 'registration_registrationType_carrier_dealer'
  click_on 'Next'
end

And(/^I enter my business details$/) do
  fill_in 'registration_companyName', with: 'Bespoke'
  fill_in 'sPostcode', with: 'BS1 5AH'
  click_on 'Find UK address'

  select 'Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH'
  click_on 'Next'
end

And(/^I enter my contact details$/) do
  fill_in 'registration_firstName', with: 'Joe'
  fill_in 'registration_lastName', with: 'Bloggs'
  fill_in 'registration_phoneNumber', with: '0117 926 9999'
  fill_in 'registration_contactEmail', with: my_email_address
  click_on 'Next'
end

And(/^I confirm the declaration$/) do
  check 'registration_declaration'
  click_on 'Confirm'
end

Given(/^I enter new user account details$/) do
  fill_in 'registration_accountEmail', with: my_email_address
  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password

  click_on 'Next'
end

And(/^I choose pay via electronic transfer$/) do
  click_on 'Pay via electronic transfer'
  click_on 'Next'
end

Then(/^I am registered as an upper tier waste carrier$/) do
  page.should have_content 'is registered as an upper tier waste carrier'
  open_email my_email_address
  current_email.should have_content 'is registered as an upper tier waste carrier'
end

And(/^no key people in the organisation have convictions$/) do
  choose 'No'
  click_on 'Next'
end
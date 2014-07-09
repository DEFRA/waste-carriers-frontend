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

And(/^I go past the payment page$/) do
  click_on 'Pay by debit/credit card'
end

Then(/^I am registered as an upper tier waste carrier$/) do
  page.should have_content 'is registered as an upper tier waste carrier'
  open_email my_email_address
  current_email.should have_content 'is registered as an upper tier waste carrier'
end

Given(/^I have gone through the upper tier waste carrier process$/) do
  visit find_path

  choose 'registration_businessType_soletrader'
  click_on 'Next'
  choose 'registration_otherBusinesses_yes'
  click_on 'Next'
  choose 'registration_isMainService_yes'
  click_on 'Next'
  choose 'registration_onlyAMF_no'
  click_on 'Next'

  click_on 'registration_registrationType_carrier_dealer'
  click_pn 'Next'

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

  check 'registration_declaration'
  click_on 'Confirm'

  fill_in 'registration_accountEmail', with: my_email_address
  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password

  click_on 'Next'

  click_on 'Pay by electronic transfer'
  click_on 'Next'
end
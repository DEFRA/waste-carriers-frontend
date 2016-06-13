Given(/^I have completed the upper tier and chosen to pay by bank transfer$/) do
  step 'I have been funneled into the upper tier path'
  step 'I am a carrier dealer'
  step 'I enter my business details'
  step 'I enter my contact details'
  postal_address_page_complete_form
  step 'I enter the details of the business owner'
  step 'no key people in the organisation have convictions'
  step 'I confirm the declaration'
  step 'I enter new user account details'
  step 'I choose pay via electronic transfer'
end

Given(/^I have been funneled into the upper tier path$/) do
  visit business_type_path
  choose 'registration_businessType_soletrader'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
  choose 'registration_isMainService_yes'
  click_button 'continue'
  choose 'registration_onlyAMF_no'
  click_button 'continue'
end

Given(/^I am a partnership on the upper tier path$/) do
  visit business_type_path
  choose 'registration_businessType_partnership'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
  choose 'registration_isMainService_yes'
  click_button 'continue'
  choose 'registration_onlyAMF_no'
  click_button 'continue'
end

And(/^I am a carrier dealer$/) do
  choose 'registration_registrationType_carrier_dealer'
  click_button 'continue'
end

And(/^I enter my business details$/) do
  fill_in 'registration_companyName', with: my_company_name
  fill_in 'sPostcode', with: 'BS1 5AH'
  click_button 'find_address'

  #select 'Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH'
  select 'ENVIRONMENT AGENCY, HORIZON HOUSE, DEANERY ROAD, BRISTOL, BS1 5AH'
  click_button 'continue'
end

And(/^I enter my contact details$/) do
  fill_in 'registration_firstName', with: 'Joe'
  fill_in 'registration_lastName', with: 'Bloggs'
  fill_in 'registration_phoneNumber', with: '0117 926 9999'
  fill_in 'registration_contactEmail', with: my_email_address
  click_button 'continue'
end

And(/^I confirm the declaration$/) do
  check 'registration_declaration'
  click_button 'confirm'
end

Given(/^I enter new user account details$/) do
  fill_in 'registration_accountEmail', with: my_email_address
  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password

  click_button 'continue'
end

And(/^I choose pay via electronic transfer$/) do
  choose 'registration_payment_type_bank_transfer'
  click_button 'proceed_to_payment'

  click_button 'continue'
end

Then(/^I am registered as an upper tier waste carrier$/) do
  do_short_pause_for_email_delivery
  open_email my_email_address
  expect(current_email).to have_text 'you need to renew your registration every 3 years'
end

Then(/^I am successfully registered and activated as an upper tier waste carrier$/) do
  expect(page).to have_text 'Signed in as'
  expect(page).to have_text 'CBDU'
  expect(page).to have_text 'ACTIVE'
end

# TODO: Update this test once we have defined content for the convictions email
Then(/^I am registered as an upper tier waste carrier pending conviction checks$/) do
  do_short_pause_for_email_delivery
  open_email my_email_address
  expect(current_email).to have_text 'What happens next'
end

Then(/^I am registered and activated as an upper tier waste carrier pending conviction checks$/) do
  expect(page).to have_text 'Signed in as'
  expect(page).to have_text 'CBDU'
  expect(page).to have_text 'PENDING'
end

# TODO: Update this test once we have defined content for the awaiting payment
# email
Then(/^I am registered as an upper tier waste carrier pending payment$/) do
  do_short_pause_for_email_delivery
  open_email my_email_address
  expect(current_email).to have_text 'Application received'
end

Then(/^I am registered and activated as an upper tier waste carrier pending payment$/) do
  expect(page).to have_text 'Signed in as'
  expect(page).to have_text 'CBDU'
  expect(page).to have_text 'PENDING'
end

Then(/^I have applied as an upper tier waste carrier$/) do
  expect(page).to have_text 'Signed in as'
  expect(page).to have_text 'CBDU'
  expect(page).to have_text 'PENDING'
end

Then(/^I have completed the application as an upper tier waste carrier via electronic transfer$/) do
  expect(page).to have_text 'Please allow 5 working days for your payment to reach us'
end

And(/^no key people in the organisation have convictions$/) do
  choose 'registration_declaredConvictions_no'
  click_button 'continue'
end

And(/^key people in the organisation have convictions$/) do
  choose 'Yes'
  click_button 'continue'
end

Given(/^I finish the registration$/) do
  click_button 'finished_btn'
end
Given(/^I click on the finish button$/) do
  click_button 'finished'
end

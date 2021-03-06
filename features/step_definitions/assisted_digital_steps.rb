Given(/^I am logged in as an NCCC agency user$/) do
  visit new_agency_user_session_path
  fill_in 'Email', with: my_agency_user.email
  fill_in 'Password', with: my_agency_user.password
  click_button 'sign_in'
  expect(page).to have_selector(:id, 'agency-user-signed-in')
end

Given(/^I start a new registration on behalf of a caller$/) do
  visit registrations_path
  click_link 'new_registration'

  choose 'registration_newOrRenew_new'
  click_button 'continue'

  choose 'registration_location_england'
  click_button 'continue'
end

Given(/^the caller provides initial answers for the lower tier$/) do
  choose 'registration_businessType_charity'
  click_button 'continue'
end

Given(/^the caller provides his business organisation details$/) do
  click_link 'manual_uk_address'

  fill_in 'registration_companyName', with: 'Assisted Digital & Co'
  fill_in 'address_houseNumber', with: '12'
  fill_in 'address_addressLine1', with: 'Assisted Street'
  fill_in 'address_addressLine2', with: 'Digital City Centre'
  fill_in 'address_townCity', with: 'Bristol'
  fill_in 'address_postcode', with: 'BS1 5AH'

  click_button 'continue'
end

Given(/^the caller provides his contact details$/) do
  fill_in 'registration_firstName', with: 'Antony'
  fill_in 'registration_lastName', with: 'Assisted'
  fill_in 'registration_phoneNumber', with: '0123 456 789'

  click_button 'continue'
end

Given(/^the caller provides his postal address$/) do
  postal_address_page_complete_form
end

Given(/^the caller declares the information provided is correct$/) do
  check 'registration_declaration'

  click_button 'confirm'
end

Then(/^the registration confirmation email should not be sent$/) do
  # specifically "the registration confirmation email should not be sent *to the agency user" (for whom this is the only email address provided)
  open_email my_agency_user.email
  expect(current_email).to be_nil
end

When(/^I create a lower tier registration on behalf of a caller$/) do
  click_link 'new_registration'

  choose 'registration_newOrRenew_new'
  click_button 'continue'

  choose 'registration_location_england'
  click_button 'continue'

  choose 'registration_businessType_charity'
  click_button 'continue'

  click_link 'manual_uk_address'
  fill_in 'registration_companyName', with: 'Grades & Co'
  fill_in 'address_houseNumber', with: '12'
  fill_in 'address_addressLine1', with: 'Deanery Road'
  fill_in 'address_addressLine2', with: 'EA Building'
  fill_in 'address_townCity', with: 'Bristol'
  fill_in 'address_postcode', with: 'BS1 5AH'
  click_button 'continue'

  fill_in 'registration_firstName', with: 'Joe'
  fill_in 'registration_lastName', with: 'Bloggs'
  fill_in 'registration_phoneNumber', with: '0117 926 8332'
  click_button 'continue'

  postal_address_page_complete_form

  check 'registration_declaration'
  click_button 'confirm'

end

When(/^I create an upper tier registration on behalf of a caller who wants to pay offline$/) do
  click_link 'new_registration'

  choose 'registration_newOrRenew_new'
  click_button 'continue'

  choose 'registration_location_england'
  click_button 'continue'

  choose 'registration_businessType_soletrader'
  click_button 'continue'

  choose 'registration_otherBusinesses_yes'
  click_button 'continue'

  choose 'registration_isMainService_yes'
  click_button 'continue'

  choose 'registration_onlyAMF_no'
  click_button 'continue'

  choose 'registration_registrationType_carrier_dealer'
  click_button 'continue'

  click_link 'manual_uk_address'
  fill_in 'registration_companyName', with: 'Assisted Enterprises & Co'
  fill_in 'address_houseNumber', with: '123'
  fill_in 'address_addressLine1', with: 'Deanery Road'
  fill_in 'address_addressLine2', with: 'EA Building'
  fill_in 'address_townCity', with: 'Bristol'
  fill_in 'address_postcode', with: 'BS1 5AH'
  click_button 'continue'

  fill_in 'registration_firstName', with: 'Antony'
  fill_in 'registration_lastName', with: 'Assisted'
  fill_in 'registration_phoneNumber', with: '0123 456 789'
  click_button 'continue'

  postal_address_page_complete_form

  step 'I enter the details of the business owner'

  choose 'No'
  click_button 'continue'

  check 'registration_declaration'
  click_button 'confirm'

  choose 'registration_payment_type_bank_transfer'
  click_button 'proceed_to_payment'
end

And(/^the lower tier waste carrier registration id$/) do
  expect(page).to have_text 'The registration number is: CBDL'
end

And(/^I see the upper tier waste carrier registration id/) do
  expect(page).to have_text 'The registration number is: CBDU'
end

And(/^I see the payment details to tell the customer$/) do
  click_button 'continue'
end

Then(/^I logout$/) do
  click_button 'signout_button'
  visit destroy_agency_user_session_path
end

Then(/^the print page does not contain unnecessary content$/) do
  click_link 'view_certificate'
  expect(page).not_to have_xpath "//a[@id='logo']" # No Gov Uk Template
  # No contact details
  expect(page).not_to have_text(
    'registrations@wastecarriersregistration.service.gov.uk')
end

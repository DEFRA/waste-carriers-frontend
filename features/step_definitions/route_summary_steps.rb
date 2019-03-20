Given(/^I have come to the lower tier summary page$/) do
  visit start_path
  choose 'registration_newOrRenew_new'
  click_button 'continue'

  choose 'registration_location_england'
  click_button 'continue'

  choose 'registration_businessType_soletrader'
  click_button 'continue'

  choose 'registration_otherBusinesses_no'
  click_button 'continue'

  choose 'registration_constructionWaste_no'
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
  fill_in 'registration_contactEmail', with: my_email_address
  click_button 'continue'

  postal_address_page_complete_form
end

Then(/^I see I am a lower tier waste carrier$/) do
  expect(page).to have_text 'you are a lower tier'
end

Given(/^I have come to the upper tier summary page$/) do
  visit start_path
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

  fill_in 'registration_companyName', with: my_company_name
  fill_in 'sPostcode', with: 'BS1 5AH'
  click_button 'find_address'

  select 'NATURAL ENGLAND, HORIZON HOUSE, DEANERY ROAD, BRISTOL, BS1 5AH'
  click_button 'continue'

  fill_in 'registration_firstName', with: 'Joe'
  fill_in 'registration_lastName', with: 'Bloggs'
  fill_in 'registration_phoneNumber', with: '0117 926 9999'
  fill_in 'registration_contactEmail', with: my_email_address
  click_button 'continue'

  postal_address_page_complete_form

  step 'I enter the details of the business owner'

  choose 'No'
  click_button 'continue'
end

Then(/^I see I am an upper tier waste carrier$/) do
  expect(page).to have_text 'you are an upper tier'
end

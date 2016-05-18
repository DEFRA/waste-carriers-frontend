
#Validation notification messages

Given(/^a lower tier registration is completed$/) do

  visit business_type_path

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
  click_button 'continue'
  check 'registration_declaration'
  click_button 'confirm'

  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password
  click_button 'continue'

  sleep 0.2 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
end

Then(/^I see the confirm email screen$/) do
  expect(page). to have_text 'Confirm your email address'
end


Given(/^I am on the business or organisation details page for a Charity$/) do
  visit business_type_path
  choose 'registration_businessType_charity'
  click_button 'continue'
end

Given(/^I am on the business or organisation details page for an Authority$/) do
  visit business_type_path
  choose 'registration_businessType_authority'
  click_button 'continue'
end

When(/^I click find address without entering a trading name$/) do
  click_button 'Find address'
end

Then(/^a validation message for the trading name is displayed$/) do
  expect(page). to have_text 'You must enter the trading name of your business or organisation'
end

Given(/^I am on the business type page$/) do
  visit business_type_path
  click_button 'continue'
end

Given(/^I am on the construction waste page for a Sole trader$/) do
  visit business_type_path
  choose 'registration_businessType_soletrader'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
end

Given(/^I am on the who produces the waste page for Sole trader$/) do
  visit business_type_path
  choose 'registration_businessType_soletrader'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
end

Given(/^I am on the CBD page for a Sole trader$/) do
  visit business_type_path
  choose 'registration_businessType_soletrader'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
  choose 'registration_constructionWaste_yes'
  click_button 'continue'
end

Given(/^I am on the construction waste page for a Partnership$/) do
  visit business_type_path
  choose 'registration_businessType_partnership'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
end

Given(/^I am on the who produces the waste page for a Partnership$/) do
  visit business_type_path
  choose 'registration_businessType_partnership'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
end

Given(/^I am on the CBD page for a Partnership$/) do
  visit business_type_path
  choose 'registration_businessType_partnership'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
  choose 'registration_constructionWaste_yes'
  click_button 'continue'
end

Given(/^I am on the construction waste page for a Ltd Company$/) do
  visit business_type_path
  choose 'registration_businessType_limitedcompany'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
end

Given(/^I am on the who produces the waste page for a Ltd Company$/) do
  visit business_type_path
  choose 'registration_businessType_limitedcompany'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
end

Given(/^I am on the CBD page for a Ltd Company$/) do
  visit business_type_path
  choose 'registration_businessType_limitedcompany'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
  choose 'registration_constructionWaste_yes'
  click_button 'continue'
end

Given(/^I am on the construction waste page for a Public body$/) do
  visit business_type_path
  choose 'registration_businessType_publicbody'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
end

Given(/^I am on the who produces the waste page for a Public body$/) do
  visit business_type_path
  choose 'registration_businessType_publicbody'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
end

Given(/^I am on the CBD page for a Public body$/) do
  visit business_type_path
  choose 'registration_businessType_publicbody'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
  choose 'registration_constructionWaste_yes'
  click_button 'continue'
end


When(/^I continue without selecting an option$/) do
  click_button 'continue'
end

Then(/^a validation message for none selection is displayed$/) do
  expect(page). to have_text 'You must answer this question'
end

#--------------------------------------------

#Pre-population of sole Trader Business Owner name

Then(/^Business owner details are pre-populated$/) do
  expect(page).to have_selector("input[value='Joe']")
  expect(page).to have_selector("input[value='Bloggs']")
end


#-------------------------------------------

#Second Contact address

#If the radio button option is decided on then need to specify the name of radio button
And(/^This is not my postal address$/) do
#  choose ‘whatever_this_radio_button_is_named’
    click_button 'continue'
end

And(/^This is my postal address$/) do
  #  choose ‘whatever_this_radio_button_is_named’
    click_button 'continue'
end

#This needs the page heading or other text from the new page
#Use the second expect(page) only if radio buttons are not used
Then(/^I am directed to the postal address details page$/) do
  expect(page). to have_text 'Contact details'
  #expect(page). to have_text 'HP10 9BX' - use if no radio buttons i.e. fields pre-populated
end

Given(/^I autocomplete my business contact address$/) do
  fill_in 'sPostcode', with: 'HP10 9BX'
  click_button 'find_address'
  select '33, FENNELS WAY, FLACKWELL HEATH, HIGH WYCOMBE, HP10 9BX'
end

And(/^I can enter my postal address$/) do
#This is a temporary step definition until page is available
  fill_in 'registration_firstName', with: 'John'
  fill_in 'registration_lastName', with: 'Smith'
  fill_in 'registration_phoneNumber', with: '01248 123456'# Not required for second contact
#  fill_in 'registration_streetLine1', with: 'Broad Street'
#  fill_in 'registration_streetLine2', with: 'City Centre'
#  fill_in 'registration_streetLine3', with: 'Bristol'
#  fill_in 'registration_streetLine4', with: 'BS1 2EP'

#  fill_in 'registration_country', with: 'France'

#  click_button 'continue'
end

#------------------------------------------------------


#Validation notification messages

Given(/^a lower tier registration is completed$/) do
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
  choose 'registration_businessType_charity'
  click_button 'continue'
end

Given(/^I am on the business or organisation details page for an Authority$/) do
  choose 'registration_businessType_authority'
  click_button 'continue'
end

When(/^I click find address without entering a trading name$/) do
  click_button 'Find address'
end

Then(/^a validation message for the trading name is displayed$/) do
  expect(page). to have_text 'You must enter the trading name of your business or organisation'
end

Given(/^I am on the construction waste page for a Sole trader$/) do
  choose 'registration_businessType_soletrader'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
end

Given(/^I am on the who produces the waste page for Sole trader$/) do
  choose 'registration_businessType_soletrader'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
end

Given(/^I am on the CBD page for a Sole trader$/) do
  choose 'registration_businessType_soletrader'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
  choose 'registration_constructionWaste_yes'
  click_button 'continue'
end

Given(/^I am on the construction waste page for a Partnership$/) do
  choose 'registration_businessType_partnership'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
end

Given(/^I am on the who produces the waste page for a Partnership$/) do
  choose 'registration_businessType_partnership'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
end

Given(/^I am on the CBD page for a Partnership$/) do
  choose 'registration_businessType_partnership'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
  choose 'registration_constructionWaste_yes'
  click_button 'continue'
end

Given(/^I am on the construction waste page for a Ltd Company$/) do
  choose 'registration_businessType_limitedcompany'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
end

Given(/^I am on the who produces the waste page for a Ltd Company$/) do
  choose 'registration_businessType_limitedcompany'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
end

Given(/^I am on the CBD page for a Ltd Company$/) do
  choose 'registration_businessType_limitedcompany'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
  choose 'registration_constructionWaste_yes'
  click_button 'continue'
end

Given(/^I am on the construction waste page for a Public body$/) do
  choose 'registration_businessType_publicbody'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
end

Given(/^I am on the who produces the waste page for a Public body$/) do
  choose 'registration_businessType_publicbody'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
end

Given(/^I am on the CBD page for a Public body$/) do
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

# Second Contact address

Then('The Who Should We Write To page is pre-populated with relevant details') do
  expect(page).to have_field('address_firstName', with: 'Joe')
  expect(page).to have_field('address_lastName', with: 'Bloggs')
  expect(page).to have_field('address_houseNumber', with: '33')
  expect(page).to have_field('address_addressLine1', with: 'FENNELS WAY')
  expect(page).to have_field('address_townCity', with: 'HIGH WYCOMBE')
  expect(page).to have_field('address_postcode', with: 'HP10 9BX')
end

#------------------------------------------------------

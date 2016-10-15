Given(/^I am registering as a limited company$/) do
  choose 'registration_businessType_limitedcompany'
  click_button 'continue'
end

Given(/^I am on the business details page as an upper tier$/) do
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'

  choose 'registration_isMainService_yes'
  click_button 'continue'

  choose 'registration_onlyAMF_no'
  click_button 'continue'

  choose 'registration_registrationType_carrier_dealer'
  click_button 'continue'
end

Given(/^I am on the business details page as an lower tier$/) do
  choose 'registration_otherBusinesses_no'
  click_button 'continue'

  choose 'registration_constructionWaste_no'
  click_button 'continue'
end

And(/^I enter my company name and address$/) do
  fill_in 'registration_companyName', with: 'The Ladd Company'

  fill_in 'sPostcode', with: 'HP10 9BX'
  click_button 'find_address'
end

Given(/^I select an address$/) do
  select '33, FENNELS WAY, FLACKWELL HEATH, HIGH WYCOMBE, HP10 9BX'
end

Given(/^I enter an active company number$/) do
  fill_in 'registration_company_no', with: '02050399'
end


Given(/^I enter an inactive company number$/) do
  fill_in 'registration_company_no', with: '05868270'
end

Given(/^I enter a company number which does not exist$/) do
  fill_in 'registration_company_no', with: '99999999'
end

Given(/^I leave the company number blank$/) do
  # no-op
end

When(/^I click to advance$/) do
  click_button 'continue'
end

And(/^I remain on the upper tier business details page$/) do
  expect(page).to have_text 'Business details'
end

Then(/^I proceed to the next wizard step$/) do
  expect(page).not_to have_field 'registration_company_no'
end

Then(/^I am told the company is not active$/) do
  expect(page).to have_text 'no longer active'
end

Then(/^I am told the company was not found$/) do
  expect(page).to have_text 'can’t be found'
end

Then(/^I am told the company number needs to be filled in$/) do
  expect(page).to have_text 'You must enter the company registration number'
end

Then(/^I am not asked for my company number$/) do
  expect(page).not_to have_field 'registration_company_no'
end

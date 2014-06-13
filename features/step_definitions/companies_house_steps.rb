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
  click_on 'Next'
end

And(/^I remain on the upper tier business details page$/) do
  page.should have_content 'Enter your business details'
end

Then(/^I proceed to the next wizard step$/) do
  page.should have_content 'Director contact details'
end

Then(/^I am told the company is not active$/) do
  page.should have_content 'is not the companies house registration number of an active limited company'
end

Then(/^I am told the company was not found$/) do
  save_and_open_page
  pending
end

Then(/^I am told the company number needs to be filled in$/) do
  page.should have_content 'Company no must be completed'
end
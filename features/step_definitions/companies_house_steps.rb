Given(/^I am registering as a limited company$/) do
  visit find_path

  choose 'registration_businessType_limitedcompany'
  click_on 'Next'
end

Given(/^I am on the business details page as an upper tier$/) do
  choose 'registration_otherBusinesses_yes'
  click_on 'Next'

  choose 'registration_isMainService_yes'
  click_on 'Next'

  choose 'registration_onlyAMF_no'
  click_on 'Next'

  choose 'registration_registrationType_carrier_dealer'
  click_on 'Next'
end

Given(/^I am on the business details page as an lower tier$/) do
  choose 'registration_otherBusinesses_no'
  click_on 'Next'

  choose 'registration_constructionWaste_no'
  click_on 'Next'
end

And(/^I enter my company name and address$/) do
  fill_in 'registration_companyName', with: 'The Ladd Company'

  fill_in 'sPostcode', with: 'HP10 9BX'
  click_on 'Find UK address'
  
#
# Removed as Find UK adress now validates and thus returns errros for other fields
#  select '33 Fennels Way, Flackwell Heath HP10 9BX'
end

Given(/^I select an address$/) do
  #select '33 Fennels Way, Flackwell Heath HP10 9BX'
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
  click_on 'Next'
end

And(/^I remain on the upper tier business details page$/) do
  page.should have_content 'Enter your business details'
end

Then(/^I proceed to the next wizard step$/) do
  page.should_not have_field 'registration_company_no'
end

Then(/^I am told the company is not active$/) do
  page.should have_content 'does not have active status'
end

Then(/^I am told the company was not found$/) do
  page.should have_content 'is not listed by Companies House'
end

Then(/^I am told the company number needs to be filled in$/) do
  page.should have_content 'Companies House number must be completed'
end


Then(/^I am not asked for my company number$/) do
  page.should_not have_field 'registration_company_no'
end
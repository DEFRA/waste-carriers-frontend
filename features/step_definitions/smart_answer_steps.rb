Given(/^I start a new registration$/) do
  visit business_type_path
end

And(/^I enter my business type as (.*)$/) do |business_type|
  choose "registration_businessType_#{business_type}"
  click_button 'continue'
end

And(/^I indicate I deal only with my own waste$/) do
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
end

And(/^I indicate I deal with other people's waste too$/) do
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
end

And(/^I indicate I never deal with waste from building or demolition work$/) do
  choose 'registration_constructionWaste_no'
  click_button 'continue'
end

And(/^I indicate I sometimes deal with waste from building or demolition work$/) do
  choose 'registration_constructionWaste_yes'
  click_button 'continue'
end

Then(/^I will be on the lower tier waste carrier registration path$/) do
  page.has_no_field? 'registration_companyName'
end

Then(/^I will be on the upper tier waste carrier registration path$/) do
  page.has_no_field? 'registration_registrationType_carrier_dealer'
end

And(/^I indicate disposing waste is my main service$/) do
  choose 'registration_isMainService_yes'
  click_button 'continue'
end

And(/^I indicate disposing waste is not my main service$/) do
  choose 'registration_isMainService_no'
  click_button 'continue'
end

And(/^I indicate I only deal with animal, farm, quarry or mine waste$/) do
  choose 'registration_onlyAMF_yes'
  click_button 'continue'
end

And(/^I indicate I don't deal with animal, farm, quarry or mine waste$/) do
  choose 'registration_onlyAMF_no'
  click_button 'continue'
end

Then(/^there is a continue button on the page$/) do
  page.has_button? 'continue'
end

Then(/^there is no back button on the page/) do
  page.has_no_button? 'Back'
end

Then(/^I am told to ring the Environment Agency$/) do
  page.has_text? 'Contact the Environment Agency'
end

Given(/^I navigate to the construction\/demolition step via the other businesses step$/) do
  visit start_path
  choose 'registration_newOrRenew_new'
  click_button 'continue'
  choose 'registration_businessType_soletrader'
  click_button 'continue'
  choose 'registration_otherBusinesses_no'
  click_button 'continue'
end

Given(/^I navigate to the construction\/demolition step via the main service step$/) do
  visit start_path
  choose 'registration_newOrRenew_new'
  click_button 'continue'
  choose 'registration_businessType_soletrader'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
  choose 'registration_isMainService_yes'
  click_button 'continue'
end

When(/^I click the back link$/) do
  click_link 'back_link'
end

Then(/^I end up on the other businesses step$/) do
  expect(page).to have_xpath("//*[@id = 'registration_otherBusinesses_yes']")
end

Then(/^I end up on the main service step$/) do
  expect(page).to have_xpath("//*[@id = 'registration_isMainService_yes']")
end

When(/^I click the back link twice$/) do
  click_link 'back_link'
  sleep 0.1
  click_link 'back_link'
end

Then(/^I follow the breadcrumb trail$/) do
  expect(page).not_to have_xpath("//*[@id = 'registration_constructionWaste_yes']")
end

And(/^I end up on the business type step$/) do
  expect(page).to have_xpath("//*[@id = 'registration_businessType_soletrader']")
end

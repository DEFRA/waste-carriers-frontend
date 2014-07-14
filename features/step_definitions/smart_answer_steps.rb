Given(/^I am on the discovery page$/) do
  visit find_path
end

And(/^I enter my business type as (.*)$/) do |business_type|
  choose "registration_businessType_#{business_type}"
  click_on 'Next'
end

And(/^I indicate I deal only with my own waste$/) do
  choose 'registration_otherBusinesses_no'
  click_on 'Next'
end

And(/^I indicate I deal with other people's waste too$/) do
  choose 'registration_otherBusinesses_yes'
  click_on 'Next'
end

And(/^I indicate I never deal with waste from building or demolition work$/) do
  choose 'registration_constructionWaste_no'
  click_on 'Next'
end

And(/^I indicate I sometimes deal with waste from building or demolition work$/) do
  choose 'registration_constructionWaste_yes'
  click_on 'Next'
end

Then(/^I will be on the lower tier waste carrier registration path$/) do
  page.should have_content 'Enter your business details'
end

Then(/^I will be on the upper tier waste carrier registration path$/) do
  page.should have_content 'Carrier, broker or dealer'
end

And(/^I indicate disposing waste is my main service$/) do
  choose 'registration_isMainService_yes'
  click_on 'Next'
end

And(/^I indicate disposing waste is not my main service$/) do
  choose 'registration_isMainService_no'
  click_on 'Next'
end

And(/^I indicate I only deal with animal, farm, quarry or mine waste$/) do
  choose 'registration_onlyAMF_yes'
  click_on 'Next'
end

And(/^I indicate I don't deal with animal, farm, quarry or mine waste$/) do
  choose 'registration_onlyAMF_no'
  click_on 'Next'
end

Then(/^there is a next button on the page$/) do
  page.should have_button 'Next'
end

Then(/^there is no back button on the page/) do
  page.should_not have_button 'Back'
end

Then(/^I am told to ring the Environment Agency$/) do
  page.should have_content 'Contact the Environment Agency'
end

Given(/^I navigate to the construction\/demolition step via the other businesses step$/) do
  visit find_path
  choose 'registration_businessType_soletrader'
  click_on 'Next'
  choose 'registration_otherBusinesses_no'
  click_on 'Next'
end

Given(/^I navigate to the construction\/demolition step via the main service step$/) do
  visit find_path
  choose 'registration_businessType_soletrader'
  click_on 'Next'
  choose 'registration_otherBusinesses_yes'
  click_on 'Next'
  choose 'registration_isMainService_yes'
  click_on 'Next'
end

When(/^I click the back link$/) do
  click_on 'Back'
end

Then(/^I end up on the other businesses step$/) do
  page.should have_content 'Do you ever deal with waste from other businesses'
end

Then(/^I end up on the main service step$/) do
  page.should have_content 'What kind of service'
end

When(/^I click the back link twice$/) do
  click_on 'Back'
  sleep 0.1
  click_on 'Back'
end

Then(/^I follow the breadcrumb trail$/) do
  page.should_not have_content 'Do you ever deal with construction'
end

And(/^I end up on the business type step$/) do
  page.should have_content 'What type of business'
end

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
  page.should have_content 'Enter your business or organisation address'
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

Then(/^there is no back button on the page/) do
  page.should_not have_button 'Back'
end

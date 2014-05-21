Given(/^I am on the discovery page$/) do
  visit find_path
end

And(/^I enter my business type as (.*)$/) do |business_type|
  choose "registration_businessType_#{business_type}"
  click_on 'Next'
end
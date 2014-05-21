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

And(/^I indicate I never deal with waste from building or demolition work$/) do
  choose 'registration_constructionWaste_no'
  click_on 'Next'
end
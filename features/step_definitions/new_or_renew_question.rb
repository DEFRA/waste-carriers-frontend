Given(/^I am on the start page$/) do
  visit newOrRenew_path
  page.should have_content "Are you renewing an existing licence?"
end

When(/^I choose a new registration$/) do
  choose 'registration_newOrRenew_new'
  click_on 'Next'
end

Then(/^I will be directed to new registrations$/) do
  page.should have_content "What type of business or organisation are you?"
end



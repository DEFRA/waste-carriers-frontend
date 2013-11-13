#step definitions for user administration

Given(/^I am an administrator$/) do
  #pending # express the regexp above with the code you wish you had

  #TODO Create admin user if needed
end

When(/^I log in as administrator$/) do
  visit "/admins/sign_in"
  assert page.has_content? "Administration Login"
  fill_in "admin_email", :with => 'admin@waste-exemplar.gov.uk'
  fill_in "admin_password", :with => 'secret123'
  click_button "Sign in"
end

Then(/^I should see the user administration page$/) do
  assert page.has_content? "Signed in as admin"
  assert page.has_content? "Listing agency users"
end

Given(/^I am logged in as an administrator$/) do
  visit "/admins/sign_in"
  assert page.has_content? "Administration Login"
  fill_in "admin_email", :with => 'admin@waste-exemplar.gov.uk'
  fill_in "admin_password", :with => 'secret123'
  click_button "Sign in"
end

When(/^I elect to create a new agency user$/) do
  click_button "New agency user"
end

When(/^there is no such user yet$/) do
  AgencyUser.where(email: "joe3@waste-exemplar.gov.uk").delete
end

When(/^I fill in valid agency user details$/) do
  assert page.has_content?("New agency user")
  fill_in "agency_user_email", :with => 'joe3@waste-exemplar.gov.uk'
  fill_in "agency_user_password", :with => 'secret123'
  click_button "Create Agency User"
end

Then(/^the user should have been created$/) do
  assert(AgencyUser.where(email: 'joe3@waste-exemplar.gov.uk').exists?)
end

Then(/^I should see the user's details page$/) do
  assert page.has_content?("agency user was successfully created.")
end

Given(/^there is a user to be deleted$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I elect to delete the user$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the user should have been deleted$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I am not logged in as an administrator$/) do
  #Nothing to do
end

When(/^I access the user administration page$/) do
  visit "/agency_users"
end

Then(/^I should be prompted to login as an administrator$/) do
  assert page.has_content?("Administration Login")
  assert !page.has_content?("Listing agency users")
end

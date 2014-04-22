Given(/^I am logged in as an administrator$/) do
  visit new_admin_session_path
  page.should have_content 'Administration login'
  fill_in 'Email', with: my_admin.email
  fill_in 'Password', with: my_admin.password
  click_button 'Sign in'
end

Then(/^I should see the user administration page$/) do
  page.should have_content 'Signed in as admin'
  page.should have_content 'Listing agency users'
end

When(/^I elect to create a new agency user$/) do
  click_button 'New agency user'
end

When(/^I fill in details for an agency user$/) do
  page.should have_content 'New agency user'
  fill_in 'Email', with: agency_email_address
  fill_in 'Password', with: agency_password
  click_button 'Create agency user'
end

Then(/^the user should have been created$/) do
  page.should have_content 'Agency user was successfully created.'
  page.should have_content agency_email_address
end

Then(/^I should see the user's details page$/) do
  page.should have_content 'Agency user was successfully created.'
end

Given(/^there is a user to be deleted$/) do
  AgencyUser.where(email: "to-be-deleted@waste-exemplar.gov.uk", password: "secret123").create # TODO factory
end

When(/^I elect to delete the user$/) do
  click_link 'Delete'

  page.should have_content 'Confirm delete'
  page.should have_content 'to-be-deleted@waste-exemplar.gov.uk'
end

When(/^I confirm to delete the user$/) do
  click_button 'Delete agency user'
end

Then(/^the user should have been deleted$/) do
  page.should have_content 'Agency user was successfully deleted.'
end

When(/^I am not logged in as an administrator$/) do
  #Nothing to do
end

When(/^I access the user administration page$/) do
  visit "/agency_users"
end

Then(/^I should be prompted to login as an administrator$/) do
  page.should have_content 'Administration login'
  page.should_not have_content 'Listing agency users'
end

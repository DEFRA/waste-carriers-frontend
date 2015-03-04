Given(/^I am logged in as an administrator$/) do
  visit new_admin_session_path
  expect(page).to have_text 'Administration login'
  fill_in 'Email', with: my_admin.email
  fill_in 'Password', with: my_admin.password
  click_button 'sign_in'
end

Then(/^I should see the user administration page$/) do
  expect(page).to have_text 'Signed in successfully'
  expect(page).to have_text 'Listing agency users'
end

When(/^I elect to create a new agency user$/) do
  click_button 'new_agency_user'
end

When(/^I fill in details for an agency user$/) do
  expect(page).to have_text 'New agency user'
  fill_in 'Email', with: agency_email_address
  fill_in 'Password', with: agency_password
  click_button 'create_agency_user'
end

Then(/^the user should have been created$/) do
  expect(page).to have_text 'Agency user was successfully created.'
  expect(page).to have_text agency_email_address
end

Then(/^I should see the user's details page$/) do
  expect(page).to have_text 'Agency user was successfully created.'
end

Given(/^there is a user to be deleted$/) do
  my_agency_user
end

When(/^I elect to delete the user$/) do
  click_link 'Delete'

  expect(page).to have_text 'Confirm delete'
  expect(page).to have_text my_agency_user.email
end

When(/^I confirm to delete the user$/) do
  click_button 'delete_agency_user'
end

Then(/^the user should have been deleted$/) do
  expect(page).to have_text 'Agency user was successfully deleted.'
end

When(/^I am not logged in as an administrator$/) do
  visit destroy_admin_session_path
end

When(/^I access the user administration page$/) do
  visit new_admin_session_path
end

Then(/^I should be prompted to login as an administrator$/) do
  expect(page).to have_text 'Administration login'
  page.has_no_text? 'Listing agency users'
end

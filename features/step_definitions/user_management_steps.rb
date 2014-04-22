When(/^I log in as administrator$/) do
  visit new_admin_session_path
  assert page.has_content? "Administration login"
  fill_in 'Email', with: my_admin.email
  fill_in 'Password', with: my_admin.password
  click_button 'Sign in'
end

Then(/^I should see the user administration page$/) do
  assert page.has_content? "Signed in as admin"
  assert page.has_content? "Listing agency users"
end

Given(/^I am logged in as an administrator$/) do
  @admin = FactoryGirl.create :admin
  visit new_admin_session_path
  assert page.has_content? "Administration login"
  fill_in 'Email', with: my_admin.email
  fill_in 'Password', with: my_admin.password
  click_button 'Sign in'
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
  click_button "Create agency user"
end

Then(/^the user should have been created$/) do
  assert page.has_content? "Agency user was successfully created."
  page.should have_content "joe3@waste-exemplar.gov.uk"
end

Then(/^I should see the user's details page$/) do
  assert page.has_content?("Agency user was successfully created.")
end

Given(/^there is a user to be deleted$/) do
  AgencyUser.where(email: "to-be-deleted@waste-exemplar.gov.uk", password: "secret123").create
end

When(/^I elect to delete the user$/) do
  #TODO find a better way to identify the link?
  id = AgencyUser.find_by(email: "to-be-deleted@waste-exemplar.gov.uk").id.to_s

  within(:xpath, "//tr[@id='agency_user_" + id +"']") do
    click_link "Delete"
  end
  assert page.has_content?("Confirm delete")
  assert page.has_content?("to-be-deleted@waste-exemplar.gov.uk")
end

When(/^I confirm to delete the user$/) do
  click_button "Delete agency user"
end

Then(/^the user should have been deleted$/) do
  assert page.has_content?("Agency user was successfully deleted.")
end

When(/^I am not logged in as an administrator$/) do
  #Nothing to do
end

When(/^I access the user administration page$/) do
  visit "/agency_users"
end

Then(/^I should be prompted to login as an administrator$/) do
  assert page.has_content?("Administration login")
  assert !page.has_content?("Listing agency users")
end

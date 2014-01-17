#step definitions for authentication

Given(/^there is an activated user Joe$/) do
  if !User.where(email: 'joe.activated@wastecarrier.com').exists?
    User.where(email: 'joe.activated@wastecarrier.com').delete
  end
  user = User.new
  user.email = 'joe.activated@wastecarrier.com'
  user.password = 'secret123'
  user.send_confirmation_instructions
  user.confirm!
  user.save!
end

When(/^the user visits the login page$/) do
  visit '/users/sign_in'
end

When(/^enters valid credentials for user Joe$/) do
  assert page.has_content?("Sign in")
  fill_in "user_email", :with => 'joe.activated@wastecarrier.com'
  fill_in "user_password", :with => 'secret123'
  click_button "Sign in"
end

Then(/^the user should be logged in successfully$/) do
  assert page.has_content?("Signed in as")
end

When(/^enters invalid credentials for user Joe$/) do
  assert page.has_content?("Sign in")
  fill_in "user_email", :with => 'joe.activated@wastecarrier.com'
  fill_in "user_password", :with => 'secret234'
  click_button "Sign in"
end

Then(/^the user should see a login error$/) do
  assert page.has_content?("Invalid email or password.")
end


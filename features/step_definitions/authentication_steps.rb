#step definitions for authentication

Given(/^there is an activated user Joe$/) do
  User.destroy_all(email: 'joe.activated@example.com') # TODO probably don't need to do this now DB is working
  user = User.new # TODO factory
  user.email = 'joe.activated@example.com'
  user.password = 'secret123'
  #user.send_confirmation_instructions
  #user.confirm!
  user.skip_confirmation!
  user.save!
end

When(/^the user visits the login page$/) do
  visit new_user_session_path
end

When(/^enters valid credentials for user Joe$/) do
  page.should have_content 'Sign in'
  fill_in 'Email', with: 'joe.activated@example.com'
  fill_in 'Password', with: 'secret123'
  click_button 'Sign in'
end

Then(/^the user should be logged in successfully$/) do
  page.should have_content 'Signed in as'
end

When(/^enters invalid credentials for user Joe$/) do
  page.should have_content 'Sign in'
  fill_in 'Email', with: 'joe.activated@example.com'
  fill_in 'Password', with: 'secret234'
  click_button 'Sign in'
end

Then(/^the user should see a login error$/) do
  page.should have_content 'Invalid email or password.'
end


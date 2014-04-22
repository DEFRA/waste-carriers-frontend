Given(/^there is an activated user$/) do
  open_email my_user.email
  current_email.click_link 'Confirm your account'
end

When(/^the user visits the login page$/) do
  visit new_user_session_path
end

When(/^enters valid credentials$/) do
  page.should have_content 'Sign in'
  fill_in 'Email', with: my_user.email
  fill_in 'Password', with: my_user.password
  click_button 'Sign in'
end

Then(/^the user should be logged in successfully$/) do
  page.should have_content 'Signed in as'
end

When(/^enters invalid credentials for user Joe$/) do
  page.should have_content 'Sign in'
  fill_in 'Email', with: my_user.email
  fill_in 'Password', with: 'incorrect_password'
  click_button 'Sign in'
end

Then(/^the user should see a login error$/) do
  page.should have_content 'Invalid email or password.'
end


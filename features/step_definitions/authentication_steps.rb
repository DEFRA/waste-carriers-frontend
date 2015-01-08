Given(/^there is an activated user$/) do
  open_email my_user.email
  current_email.click_link 'confirmation_link'
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

When(/^enters invalid credentials$/) do
  page.should have_content 'Sign in'
  fill_in 'Email', with: my_user.email
  fill_in 'Password', with: 'incorrect_password'
  click_button 'Sign in'
end

And(/^the maximum number of invalid login attempts is exceeded$/) do

  # +1 to cause unlock email
  maxAttempts = Devise.maximum_attempts.to_i + 1

  maxAttempts.times do
    step "enters invalid credentials"
  end

end

Then(/^the user should see a login account locked email$/) do
  open_email my_user.email
  current_email.should have_content 'Your account has been locked temporarily'
end

And(/^I click the unlock account link$/) do
  current_email.click_link 'Unlock my account'
end

Then(/^the user should see a login account unlocked successfully page$/) do
  page.should have_content 'Your account has been unlocked successfully'
end

Then(/^the user should see a login error$/) do
  page.should have_content 'Invalid email or password.'
end

# TODO GM - still need to figure out how to switch between www and admin subdomains in Cucumber

When(/^the user tries to access the internal admin login URL from the public domain$/) do
  base_url = 'http://' + Rails.configuration.waste_exemplar_frontend_url
  url = base_url + new_user_session_path
  visit url
end

Then(/^the page is not found$/) do
  page.should_not have_content "Sign in"
end

When(/^the user tries to access the internal agency login URL from the public domain$/) do
  base_url = 'http://' + Rails.configuration.waste_exemplar_frontend_url
  url = base_url + new_agency_user_session_path
  visit url
end

When(/^the user tries to access the internal admin login URL from the admin domain$/) do
  base_url = 'http://' + Rails.configuration.waste_exemplar_frontend_admin_url
  url = base_url + new_admin_session_path
  visit url
end

Then(/^the admin login page is shown$/) do
  page.should have_content "Sign in"
end

When(/^the user tries to access the internal agency login URL from the admin domain$/) do
  base_url = 'http://' + Rails.configuration.waste_exemplar_frontend_admin_url
  url = base_url + new_agency_user_session_path
  visit url
end

Then(/^the agency user login page is shown$/) do
  page.should have_content "Sign in"
end

When(/^the user tries to access the user login URL from the internal admin domain$/) do
  base_url = 'http://' + Rails.configuration.waste_exemplar_frontend_admin_url
  url = base_url + new_user_session_path
  visit url
end

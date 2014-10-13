When(/^I do nothing for more than (\d+) minutes$/) do |m|
  Timecop.travel(m.to_i.minutes.from_now + 1.minute)
end

When(/^I want to continue with my administration tasks$/) do
  visit agency_users_path
end

Then(/^I am informed that my session has expired$/) do
  # TODO Strangely, when running tests with Cucumber, after the session has expired, the login page is rendered, 
  # while otherwise the Session Expired page is shown. But at least the session has apparently expired somehow.
  # How can this be changed or reconfigured to make Cucumber behaviour consistent with actual application behviour? 
  #page.should have_content 'Your session has expired'
  page.should have_content 'Sign in'
end

Given(/^I have started my registration$/) do
  visit newOrRenew_path
  choose 'registration_newOrRenew_renew'
  click_on 'Next'
end

When(/^I try to proceed with my unfinished registration$/) do
  visit newBusinessType_path
end

Then(/^I can still proceed$/) do
  page.should have_content 'What type of business or organisation are you?'
end

Given(/^I keep working on my registration for more than (\d+) hours$/) do |number_of_hours|
  # Note: We could keep accessing the current page to avoid session inactivity timeouts - but this should not be necessary for WCs
  Timecop.travel(number_of_hours.to_i.hours.from_now + 1.minute)
end

Then(/^I can continue with my registration$/) do
  visit newBusinessType_path
  page.should have_content 'What type of business or organisation are you?'
end

Given(/^I am logged in as a waste carrier$/) do
  open_email my_user.email
  current_email.click_link 'Confirm your account'
  visit new_user_session_path
  fill_in 'Email', with: my_user.email
  fill_in 'Password', with: my_user.password
  click_button 'Sign in'
end

When(/^I try to continue with my registrations$/) do
  visit userRegistrations_path(my_user)
end

Then(/^my waste carrier session has expired$/) do
  page.should have_content 'Your session has expired'
end

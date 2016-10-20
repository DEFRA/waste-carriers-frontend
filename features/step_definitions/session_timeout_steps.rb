When(/^I do nothing for more than (\d+) minutes$/) do |m|
  Timecop.travel(m.to_i.minutes.from_now + 1.minute)
end

When(/^I want to continue with my administration tasks$/) do
  visit new_admin_session_path
end

Then(/^I am informed that my session has expired$/) do
  expect(page).to have_text 'Your session has expired'
end

Given(/^I have started my registration$/) do
  visit start_path
  choose 'registration_newOrRenew_renew'
  click_button 'continue'
end

# When(/^I try to proceed with my unfinished registration$/) do
#   visit business_type_path
# end

Then(/^I can still proceed$/) do
  expect(page).to have_text 'What type of business or organisation are you?'
end

Given(/^I keep working on my registration for more than (\d+) hours$/) do |number_of_hours|
  # Note: We could keep accessing the current page to avoid session inactivity timeouts - but this should not be necessary for WCs
  Timecop.travel(number_of_hours.to_i.hours.from_now + 1.minute)
end

# Then(/^I can continue with my registration$/) do
#   visit business_type_path
#   expect(page).to have_text 'What type of business or organisation are you?'
# end

Given(/^I am logged in as a waste carrier$/) do
  open_email my_user.email
  current_email.click_link 'confirmation_link'
  visit new_user_session_path
  fill_in 'Email', with: my_user.email
  fill_in 'Password', with: my_user.password
  click_button 'sign_in'
end

When(/^I try to continue with my registrations$/) do
  visit user_registrations_path(my_user)
end

Then(/^my waste carrier session has expired$/) do
  expect(page).to have_text 'Your session has expired'
end

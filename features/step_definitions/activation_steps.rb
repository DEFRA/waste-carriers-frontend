When(/^I activate the account within the permissible timeout period$/) do

  timeoutPeriodEnd = Devise.confirm_within.to_i

  Timecop.travel(timeoutPeriodEnd.from_now - 1.minute) do
    visit business_type_path # refreshes page so don't get timed out after 20 minutes
    sleep 1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
    open_email my_email_address
    current_email.click_link 'confirmation_link'
  end
end

When(/^I attempt to activate the account after the permissible timeout period$/) do

  timeoutPeriodEnd = Devise.confirm_within.to_i

  Timecop.travel(timeoutPeriodEnd.from_now + 1.minute) do
    visit business_type_path # refreshes page so don't get timed out after 20 minutes
    sleep 1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
    open_email my_email_address
    current_email.click_link 'confirmation_link'
  end
end

But(/^I have not confirmed my email address$/) do
  # no-op
end

When(/^I have confirmed my email address$/) do
  sleep 1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.click_link 'confirmation_link'
end

Given(/^I have received an awaiting payment email$/) do
  sleep 1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.has_text? 'Application received'
end

When(/^I attempt to sign in$/) do
  visit new_user_session_path
  fill_in 'user_email', with: my_email_address
  fill_in 'user_password', with: my_password
  click_button 'sign_in'
 end

When(/^I log in to the '(.+)' account$/) do |email_address|
  visit new_user_session_path
  fill_in 'user_email', with: email_address
  fill_in 'user_password', with: my_password
  click_button 'sign_in'
   page.has_text? 'Your registrations'
end

Then(/^my account should not be locked, and I should be able to log in to my account$/) do
  expect(User.find_by(email: my_email_address).access_locked?).to be false
  step "I log in to the '#{my_email_address}' account"
end

When(/^I request that account confirmation instructions are re-sent for '(.+)'$/) do |email_address|
  visit new_user_confirmation_path
  fill_in 'user_email', with: email_address
  click_button 'resend'
  sleep 0.5   # Wait for the email to be 'delivered'
end

Then(/^the inbox for '(.+)' should contain an email stating that the account is already confirmed$/) do |email_address|
  open_email email_address
  expect(current_email).to have_selector(:id, 'account_already_confirmed_email')
  current_email.click_link 'sign_in_link'
  expect(URI.parse(current_url).path).to eq(new_user_session_path)
end

When(/^my account becomes locked due to several successive failed sign-in attempts$/) do
  (Devise.maximum_attempts.to_i + 1).times do
    visit new_user_session_path
    fill_in 'Email', with: my_email_address
    fill_in 'Password', with: 'this_is_the_wrong_password'
    click_button 'sign_in'
    page.has_text? 'Invalid email or password'
  end
  expect(User.find_by(email: my_email_address).access_locked?).to be true
end

And(/^I am shown my pending registration$/) do
  page.has_no_text? 'confirm your account'
  page.has_text? 'Your reference number is'
end

Then(/^my account is successfully activated$/) do
  page.has_text? 'Your registration number is'
end

When(/^I activate my account by clicking the link in the activation email$/) do
  open_email my_email_address
  activation_email_found = false

  # Cycle through all emails in the inbox to find the activation email...
  current_emails.each do |this_email|
    if (this_email.subject == 'Verify your email address')
      activation_email_found = true
      this_email.click_link 'confirmation_link'
      break
    end
  end

  # ... if we didn't find the activation email, produce an error that will be
  # meaningful to Cucumber.
  unless activation_email_found
    current_email.subject.has_text? 'Verify your email address'
  end
end

Then(/^I need to request a new confirmation email to activate my account$/) do
  click_button 'resend'
  sleep 2 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.click_link 'confirmation_link'
  page.has_text? 'Your registration number is'
end

Then(/^I am told to confirm my email address$/) do
  page.has_text? 'confirm your account'
end

Then(/^I am shown my confirmed registration$/) do
  page.has_no_text? have_content 'confirm your account'
  page.has_text? 'Your registration number is'
end

Then(/^I am not shown how to pay in my confirmation email$/) do
  sleep 2 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.has_no_text? 'How to pay'
end

Then(/^I am shown the sign in page$/) do
  page.has_text? 'Sign in'
end

Then(/I am shown the 'email address confirmed' page$/) do
  page.has_text? 'Email address confirmed'
end

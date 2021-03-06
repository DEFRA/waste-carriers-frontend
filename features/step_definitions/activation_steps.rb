When(/^I activate the account within the permissible timeout period$/) do

  timeoutPeriodEnd = Devise.confirm_within

  Timecop.travel(timeoutPeriodEnd.from_now - 1.minute) do
    visit start_path # refreshes page so don't get timed out after 20 minutes
    do_short_pause_for_email_delivery
    open_email my_email_address
    current_email.click_link 'confirmation_link'
  end
end

When(/^I attempt to activate the account after the permissible timeout period$/) do

  timeoutPeriodEnd = Devise.confirm_within

  Timecop.travel(timeoutPeriodEnd.from_now + 1.minute) do
    visit start_path # refreshes page so don't get timed out after 20 minutes
    do_short_pause_for_email_delivery
    open_email my_email_address
    current_email.click_link 'confirmation_link'
  end
end

But(/^I have not confirmed my email address$/) do
  # no-op
end

Given(/^I have received an awaiting payment email$/) do
  do_short_pause_for_email_delivery
  open_email my_email_address
  expect(current_email).to have_text 'Application received'
end

When(/^I attempt to sign in$/) do
  visit new_user_session_path
  fill_in 'user_email', with: my_email_address
  fill_in 'user_password', with: my_password
  click_button 'sign_in'
 end

When(/^I request that account confirmation instructions are re-sent for '(.+)'$/) do |email_address|
  visit new_user_confirmation_path
  fill_in 'user_email', with: email_address
  click_button 'send_instructions_button'
  do_short_pause_for_email_delivery
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
    expect(page).to have_text 'Invalid email or password'
  end
  expect(User.find_by(email: my_email_address).access_locked?).to be true
end

And(/^I am shown my pending registration$/) do
  expect(page).not_to have_text 'confirm your account'
  expect(page).to have_text 'Please use this reference number if you contact us:'
end

Then(/^my account is successfully activated$/) do
  expect(page).to have_text 'Your registration number is'
end

When(/^I activate my account by clicking the link in the activation email$/) do
  open_email my_email_address
  activation_email_found = false

  # Cycle through all emails in the inbox to find the activation email...
  current_emails.each do |this_email|
    if (this_email.subject == 'Confirm your email address')
      activation_email_found = true
      this_email.click_link 'confirmation_link'
      break
    end
  end

  # ... if we didn't find the activation email, produce an error that will be
  # meaningful to Cucumber.
  unless activation_email_found
    expect(current_email.subject).to have_text 'Confirm your email address'
  end
end

Then(/^I need to request a new confirmation email to activate my account$/) do
  click_button 'send_instructions_button'
  do_short_pause_for_email_delivery
  open_email my_email_address
  current_email.click_link 'confirmation_link'
  expect(page).to have_text 'Your registration number is'
end

Then(/^I am told to confirm my email address$/) do
  expect(page).to have_text 'confirm your email'
end

Then(/^I am shown my confirmed registration$/) do
  expect(page).to_not have_text 'confirm your email'
  expect(page).to have_text 'Your registration number is'
end

Then(/^I am not shown how to pay in my confirmation email$/) do
  do_short_pause_for_email_delivery
  open_email my_email_address
  expect(current_email).not_to have_text 'How to pay'
end

Then(/I am shown the 'email address confirmed' page$/) do
  expect(page).to have_text 'Email address confirmed'
end

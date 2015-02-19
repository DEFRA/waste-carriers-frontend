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
  current_email.should have_content 'Application received'
end

When(/^I attempt to sign in$/) do
  visit new_user_session_path
  fill_in 'user_email', with: my_email_address
  fill_in 'user_password', with: my_password
  click_button 'sign_in'
 end
 
 When(/^I log in to the "(.+)" account$/) do |email_address|
   visit new_user_session_path
   fill_in 'user_email', with: email_address
   fill_in 'user_password', with: my_password
   click_button 'sign_in'
   page.should have_content 'Your registrations'
end

And(/^I am shown my pending registration$/) do
  page.should_not have_content 'confirm your account'
  page.should have_content 'Your reference number is'
end

Then(/^my account is successfully activated$/) do
  page.should have_content 'Your registration number is'
end

Given(/^I re-request activation for my account$/) do
  visit new_user_confirmation_path
  fill_in 'user_email', with: my_email_address
  click_button 'resend'
  sleep 2 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.click_link 'confirmation_link'

  if !page.body.to_s.include?('Your account has been activated successfully')
    puts '... Waiting 5 seconds for page to load'
    sleep 5.0
    if !page.body.to_s.include?('Your account has been activated successfully')
      puts '... Waiting a further 15 seconds for for page to load'
      sleep 15.0
    end
  end

  page.should have_content 'Your account has been activated successfully'

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

  # ... if we didn't find the activation email, produce an error that will be meaningful to Cucumber.
  unless activation_email_found
    current_email.subject.should == 'Verify your email address'
  end
end

Then(/^I need to request a new confirmation email to activate my account$/) do
  click_button 'resend'
  sleep 2 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.click_link 'confirmation_link'
  page.should have_content 'Your registration number is'
end

Then(/^I am told to confirm my email address$/) do
  page.should have_content 'confirm your account'
end

Then(/^I am shown my confirmed registration$/) do
  page.should_not have_content 'confirm your account'
  page.should have_content 'Your registration number is'
end

Then(/^I am not shown how to pay in my confirmation email$/) do
  sleep 2 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.should_not have_content 'How to pay'
end

Then(/^I am shown the sign in page$/) do
  page.should have_content 'Sign in'
end

Then(/I am shown the 'email address confirmed' page$/) do
  page.should have_content 'Email address confirmed'
end

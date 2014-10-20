When(/^I activate the account within (\d+) hours$/) do |number_of_hours|
  Timecop.travel(number_of_hours.to_i.hours.from_now - 1.minute) do
    visit find_path # refreshes page so don't get timed out after 20 minutes
    sleep 1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
    open_email my_email_address
    current_email.click_link 'Confirm your account'
  end
end

When(/^I attempt to activate the account after (\d+) hours$/) do |number_of_hours|
  Timecop.travel(number_of_hours.to_i.hours.from_now + 1.minute) do
    visit find_path # refreshes page so don't get timed out after 20 minutes
    sleep 1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
    open_email my_email_address
    current_email.click_link 'Confirm your account'
  end
end

But(/^I have not confirmed my email address$/) do
  # no-op
end

When(/^I have confirmed my email address$/) do
  sleep 1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.click_link 'Confirm your account'
end

Given(/^I have received an awaiting payment email$/) do
  sleep 1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.should have_content 'Your registration requires payment'
end

When(/^I attempt to sign in$/) do
  visit new_user_session_path
  fill_in 'user_email', with: my_email_address
  fill_in 'user_password', with: my_password
  click_on 'Sign in'
 end

And(/^I am shown my pending registration$/) do
  page.should_not have_content 'confirm your account'
  page.should have_content 'is not yet registered as an upper tier waste carrier'
end

Then(/^my account is successfully activated$/) do
  page.should have_content 'Your registration number is: CBD'
end

Given(/^I re-request activation for my account$/) do
  visit new_user_confirmation_path
  fill_in 'user_email', with: my_email_address
  click_on 'Resend confirmation instructions'
  sleep 2 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.click_link 'Confirm your account'
  
  if !page.body.to_s.include?('Your account has been activated successfully')
    puts '... Waiting 5 seconds for page to load'
    sleep 5.0
    if page.body.to_s.include?(waitMessage1) || page.body.to_s.include?(waitMessage2)
      puts '... Waiting a further 15 seconds for for page to load'
      sleep 15.0
    end
  end
  
  page.should have_content 'Your account has been activated successfully'
  
end

Then(/^I need to request a new confirmation email to activate my account$/) do
  click_on 'Resend confirmation instructions'
  sleep 2 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.click_link 'Confirm your account'
  page.should have_content 'Your registration number is: CBD'
end

Then(/^I am told to confirm my email address$/) do
  page.should have_content 'confirm your account'
end

Then(/^I am shown my confirmed registration$/) do
  page.should_not have_content 'confirm your account'
  page.should have_content 'Registration complete'
end

Then(/^I am not shown how to pay in my confirmation email$/) do
  sleep 2 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.should_not have_content 'How to pay'
end

Then(/^I am shown the sign in page$/) do
  page.should have_content 'Sign in'
end

When(/^I activate the account within (\d+) hours$/) do |number_of_hours|
  Timecop.travel(number_of_hours.to_i.hours.from_now - 1.minute) do
    visit find_path # refreshes page so don't get timed out after 20 minutes
    open_email my_email_address
    current_email.click_link 'Confirm your account'
  end
end

When(/^I attempt to activate the account after (\d+) hours$/) do |number_of_hours|
  Timecop.travel(number_of_hours.to_i.hours.from_now + 1.minute) do
    visit find_path # refreshes page so don't get timed out after 20 minutes
    open_email my_email_address
    current_email.click_link 'Confirm your account'
  end
end

Then(/^my account is successfully activated$/) do
  page.should have_content 'Your registration number is: CBD'
end

Then(/^I need to request a new confirmation email to activate my account$/) do
  click_on 'Resend confirmation instructions'
  sleep 0.1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.click_link 'Confirm your account'
  page.should have_content 'Your registration number is: CBD'
end

When(/^I have not confirmed my email address$/) do
  # no-op
end

When(/^I have confirmed my email address$/) do
  open_email my_email_address
  current_email.click_link 'Confirm your account'
end

Then(/^I am told to confirm my email address$/) do
  page.should have_content 'confirm your account'
end

Then(/^I am shown my confirmed registration$/) do
  page.should_not have_content 'confirm your account'
  page.should have_content 'Registration complete'
end

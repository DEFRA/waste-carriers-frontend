When(/^I activate the account within (\d+) hours$/) do |number_of_hours|
  Timecop.travel(number_of_hours.to_i.hours.from_now - 1.minute) do
    visit find_path # refreshes page so don't get timed out after 20 minutes
    open_email 'barry@grades.co.uk' # TODO knows my email address
    current_email.click_link 'Confirm your account'
  end
end

When(/^I attempt to activate the account after (\d+) hours$/) do |number_of_hours|
  Timecop.travel(number_of_hours.to_i.hours.from_now + 1.minute) do
    visit find_path # refreshes page so don't get timed out after 20 minutes
    open_email 'barry@grades.co.uk'
    current_email.click_link 'Confirm your account'
  end
end

Then(/^my account is successfully activated$/) do
  page.should have_content 'Your registration number is'
end

Then(/^I need to request a new confirmation email$/) do
  page.should have_button 'Resend confirmation instructions'
  # TODO do rest of process
end


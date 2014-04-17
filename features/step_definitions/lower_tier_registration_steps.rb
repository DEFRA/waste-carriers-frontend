Given(/^I have completed the lower tier registration form$/) do
  visit find_path
  select 'Sole trader', from: 'What kind of business or organisation are you?'
  choose 'Only waste from our own business or organisation'
  choose 'No'
  click_on 'Continue'

  fill_in 'Business, organisation or trading name', with: 'Grades'
  click_on 'Next'

  fill_in 'Find address using postcode', with: 'BS1 2EP'
  click_on 'Find address'

  select 'Grades Gents Hairdressers, 44 Broad Street, City Centre, Bristol BS1 2EP'

  email_address = 'barry@grades.co.uk'
  select 'Mr', from: 'Title'
  fill_in 'First name', with: 'Barry'
  fill_in 'Last name', with: 'Butler'
  fill_in 'Job title', with: 'Chief Barber'
  fill_in 'Phone number', with: '0117 926 8332'
  fill_in 'Email address', with: email_address
  click_on 'Next'

  check 'By ticking this box I declare'
  click_on 'Next'

  password = 'password123'
  fill_in 'Confirm email', with: email_address
  fill_in 'Create password', with: password
  fill_in 'Confirm password', with: password
  click_on 'Next'

  sleep 0.1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
end
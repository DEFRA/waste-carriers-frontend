Given(/^I have completed the lower tier registration form$/) do
  visit find_path
  choose 'Sole trader'
  click_on 'Next'
  choose 'Only waste from our own business or organisation'
  click_on 'Next'
  choose 'No'
  click_on 'Next'

  fill_in 'Business, organisation or trading name', with: 'Grades'
  click_on 'Next'

  fill_in 'Find address using postcode', with: 'BS1 2EP'
  click_on 'Find address'

  select 'Grades Gents Hairdressers, 44 Broad Street, City Centre, Bristol BS1 2EP'

  select 'Mr', from: 'Title'
  fill_in 'First name', with: 'Joe'
  fill_in 'Last name', with: 'Bloggs'
  fill_in 'Job title', with: 'Chief Barber'
  fill_in 'Phone number', with: '0117 926 8332'
  fill_in 'Email address', with: my_email_address
  click_on 'Next'

  check 'By ticking this box I declare'
  click_on 'Next'

  fill_in 'Confirm email', with: my_email_address
  fill_in 'Create password', with: my_password
  fill_in 'Confirm password', with: my_password
  click_on 'Next'

  sleep 0.1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
end

Given(/^I have been funneled into the lower tier path$/) do
  visit find_path

  choose "registration_businessType_soletrader"
  click_on 'Next'

  choose 'registration_otherBusinesses_no'
  click_on 'Next'

  choose 'registration_constructionWaste_no'
  click_on 'Next'
end
Given(/^I have completed the lower tier registration form$/) do
  visit find_path

  choose 'registration_businessType_soletrader'
  click_on 'Next'

  choose 'registration_otherBusinesses_no'
  click_on 'Next'

  choose 'registration_constructionWaste_no'
  click_on 'Next'

  fill_in 'Business, organisation or trading name', with: 'Grades'
  click_on 'Next'

  fill_in 'sPostcode', with: 'BS1 2EP'
  click_on 'Find UK address'

  select 'Grades Gents Hairdressers, 44 Broad Street, City Centre, Bristol BS1 2EP'

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

  choose 'registration_businessType_charity'
  click_on 'Next'
end

And(/^I provide my company name$/) do
  fill_in 'registration_companyName', with: 'Grades'
end

Given(/^I autocomplete my address$/) do
  fill_in 'sPostcode', with: 'BS1 2EP'
  click_on 'Find UK address'
  select 'Grades Gents Hairdressers, 44 Broad Street, City Centre, Bristol BS1 2EP'
  click_on 'Next'
end

Given(/^I want my address autocompleted but I provide an unrecognised postcode$/) do
  fill_in 'sPostcode', with: my_unrecognised_postcode
end

Then(/^no address suggestions will be shown$/) do
  page.should have_content 'There are no addresses for the given postcode'
end

When(/^I try to select an address$/) do
  click_on 'Find UK address'
end

Given(/^I enter my address manually$/) do
  click_on 'I want to add an address myself'

  fill_in 'registration_houseNumber', with: '44'
  fill_in 'registration_streetLine1', with: 'Broad Street'
  fill_in 'registration_streetLine2', with: 'City Centre'
  fill_in 'registration_townCity', with: 'Bristol'
  fill_in 'registration_postcode', with: 'BS1 2EP'

  click_on 'Next'
end

And(/^I provide my personal contact details$/) do
  fill_in 'First name', with: 'Joe'
  fill_in 'Last name', with: 'Bloggs'
  fill_in 'Job title', with: 'Chief Barber'
  fill_in 'Phone number', with: '0117 926 8332'
  fill_in 'Email address', with: my_email_address

  click_on 'Next'
end

And(/^I check the declaration$/) do
  check 'registration_declaration'

  click_on 'Next'
end

And(/^I provide my email address and create a password$/) do
  fill_in 'registration_accountEmail', with: my_email_address
  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password

  click_on 'Next'
end

When(/^I confirm account creation via email$/) do
  open_email my_email_address
  current_email.click_link 'Confirm your account'
end

Then(/^I am registered as a lower tier waste carrier$/) do
  pending
end

But(/^I can edit this postcode$/) do
  postcode_field = find_field('sPostcode')

  postcode_field.value.should == my_unrecognised_postcode
  postcode_field['disabled'].should_not be
end

And(/^add my address manually if I wanted to$/) do
  page.should have_link 'I want to add an address myself'
end
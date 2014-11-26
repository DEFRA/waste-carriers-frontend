#
Given(/^I have completed my lower tier registration$/) do
  visit find_path

  choose 'registration_businessType_soletrader'
  click_on 'Next'

  choose 'registration_otherBusinesses_no'
  click_on 'Next'

  choose 'registration_constructionWaste_no'
  click_on 'Next'

  click_on 'I want to add an address myself'
  fill_in 'registration_companyName', with: 'Grades & Co'
  fill_in 'registration_houseNumber', with: '12'
  fill_in 'registration_streetLine1', with: 'Deanery Road'
  fill_in 'registration_streetLine2', with: 'EA Building'
  fill_in 'registration_townCity', with: 'Bristol'
  fill_in 'registration_postcode', with: 'BS1 5AH'
  click_on 'Next'

  fill_in 'registration_firstName', with: 'Joe'
  fill_in 'registration_lastName', with: 'Bloggs'
  fill_in 'registration_phoneNumber', with: '0117 926 8332'
  fill_in 'registration_contactEmail', with: my_email_address
  click_on 'Next'

  check 'registration_declaration'
  click_on 'Confirm'

  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password
  click_on 'Next'
end

Given(/^I have confirmed my user account$/) do
  sleep 1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  current_email.click_link 'confirmation_link'
end

Given(/^I have finished my registration session$/) do
  click_on 'Finish'
end

When(/^I attempt to access the previous page$/) do
  page.evaluate_script('window.history.back()')
end

Then(/^my registration data is not shown anymore$/) do
  page.should have_content 'You may have mistyped the address or the page may have moved'
end

Then(/^I am informed that I have to login again to change my registration$/) do
  page.should have_content "You can't edit"
end

When(/^I attempt to access the confirmation page$/) do
  visit newConfirmation_path
end

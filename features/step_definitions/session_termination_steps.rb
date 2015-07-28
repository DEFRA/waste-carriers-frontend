#
Given(/^I have completed my lower tier registration$/) do
  visit business_type_path

  choose 'registration_businessType_soletrader'
  click_button 'continue'

  choose 'registration_otherBusinesses_no'
  click_button 'continue'

  choose 'registration_constructionWaste_no'
  click_button 'continue'

  click_link 'manual_uk_address'

  # Needs a sleep here for some reason?, without it, companyName is not filled in generating required error
  sleep 0.1

  fill_in 'registration_companyName', with: 'Grades & Co'
  fill_in 'address_houseNumber', with: '12'
  fill_in 'address_addressLine1', with: 'Deanery Road'
  fill_in 'address_addressLine2', with: 'EA Building'
  fill_in 'address_townCity', with: 'Bristol'
  fill_in 'address_postcode', with: 'BS1 5AH'
  click_button 'continue'

  fill_in 'registration_firstName', with: 'Joe'
  fill_in 'registration_lastName', with: 'Bloggs'
  fill_in 'registration_phoneNumber', with: '0117 926 8332'
  fill_in 'registration_contactEmail', with: my_email_address
  click_button 'continue'

  postal_address_page_complete_form

  check 'registration_declaration'
  click_button 'confirm'

  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password
  click_button 'continue'
end

Given(/^I have confirmed my user account$/) do
  do_short_pause_for_email_delivery
  open_email my_email_address
  current_email.click_link 'confirmation_link'
end

Given(/^I have finished my registration session$/) do
  click_button 'finished'
end

When(/^I attempt to access the previous page$/) do
  page.evaluate_script('window.history.back()')
end

Then(/^my registration data is not shown anymore$/) do
  expect(page).to have_text 'Page not found'
end

Then(/^I am informed that I have to login again to change my registration$/) do
  expect(page).to have_text "Sorry, you can't make changes"
end

When(/^I attempt to access the confirmation page$/) do
  visit newConfirmation_path
end

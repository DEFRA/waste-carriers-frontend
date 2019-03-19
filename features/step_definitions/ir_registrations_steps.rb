

Given(/^I have signed in as an Environment Agency user$/) do
  sign_in_page_sign_in_as_environment_agency_user_and_submit
end

Then(/^I should be shown the total cost "(.*?)"$/) do |amount|
  registration_total_fee = page.find(
    :xpath,
    ".//input[@id='registration_total_fee']"
  ).value
  expect(registration_total_fee).to eq(amount)
end

When('I Enter my details') do
  fill_in 'key_person_first_name', with: 'Joe'
  fill_in 'key_person_last_name', with: 'Bloggs'
  fill_in 'key_person_dob_day', with: '01'
  fill_in 'key_person_dob_month', with: '02'
  fill_in 'key_person_dob_year', with: '1980'
  click_button 'continue'
end

When('I Enter my details for two partners') do
  fill_in 'key_person_first_name', with: 'Joe'
  fill_in 'key_person_last_name', with: 'Bloggs'
  fill_in 'key_person_dob_day', with: '01'
  fill_in 'key_person_dob_month', with: '02'
  fill_in 'key_person_dob_year', with: '1980'
  click_button 'add_btn'

  fill_in 'key_person_first_name', with: 'Joanne'
  fill_in 'key_person_last_name', with: 'Bloggs'
  fill_in 'key_person_dob_day', with: '02'
  fill_in 'key_person_dob_month', with: '03'
  fill_in 'key_person_dob_year', with: '1980'
  click_button 'continue'
end

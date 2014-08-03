And(/^I enter the details of the business owner$/) do

  fill_in 'key_person_first_name', with: 'Joe'
  fill_in 'key_person_last_name', with: 'Bloggs'
  fill_in 'key_person_dob_day', with: '01'
  fill_in 'key_person_dob_month', with: '02'
  fill_in 'key_person_dob_year', with: '1980'
  click_on 'Next'

end

And(/^I add a key person to the registration$/) do

  fill_in 'key_person_first_name', with: 'Joe'
  fill_in 'key_person_last_name', with: 'Bloggs'
  fill_in 'key_person_dob_day', with: '01'
  fill_in 'key_person_dob_month', with: '02'
  fill_in 'key_person_dob_year', with: '1980'
  click_on 'add'

end
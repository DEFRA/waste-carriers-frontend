And(/^I enter the details of the business owner$/) do
  fill_in 'key_person_first_name', with: 'Joe'
  fill_in 'key_person_last_name', with: 'Bloggs'
  fill_in 'key_person_dob_day', with: '01'
  fill_in 'key_person_dob_month', with: '02'
  fill_in 'key_person_dob_year', with: '1980'
  click_on 'next_btn'
end

And(/^I add a key person to the registration$/) do
  fill_in 'key_person_first_name', with: 'Joe'
  fill_in 'key_person_last_name', with: 'Bloggs'
  fill_in 'key_person_dob_day', with: '01'
  fill_in 'key_person_dob_month', with: '02'
  fill_in 'key_person_dob_year', with: '1980'
  click_on 'add_btn'
end

And /^I add the following key people:$/ do |table|
  table.hashes.each do |row|
    fill_in 'key_person_first_name', with: row[:first_name]
    fill_in 'key_person_last_name', with: row[:last_name]
    fill_in 'key_person_dob_day', with: row[:dob_day]
    fill_in 'key_person_dob_month', with: row[:dob_month]
    fill_in 'key_person_dob_year', with: row[:dob_year]
    click_on 'add_btn'
  end
end

Then /^I should see the following names listed:$/ do |table|
  table.hashes.each do |row|
    page.should have_content row[:first_name]
    page.should have_content row[:last_name]
  end
end

And(/^I add a key person to the registration$/) do
  fill_in 'key_person_first_name', with: 'Joe'
  fill_in 'key_person_last_name', with: 'Bloggs'
  fill_in 'key_person_dob_day', with: '01'
  fill_in 'key_person_dob_month', with: '02'
  fill_in 'key_person_dob_year', with: '1980'
  click_on 'add_btn'
end

Then(/^I should only have to enter one key person$/) do
  page.should_not have_button 'add_btn'
  page.should have_button 'next_btn'
end

Then(/^I cannot proceed until I have added a key person$/) do
  page.should_not have_button 'next_btn'
  page.should have_button 'add_btn'
end
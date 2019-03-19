And(/^I enter the details of the business owner$/) do
  fill_in 'key_person_first_name', with: 'Joe'
  fill_in 'key_person_last_name', with: 'Bloggs'
  fill_in 'key_person_dob_day', with: '01'
  fill_in 'key_person_dob_month', with: '02'
  fill_in 'key_person_dob_year', with: '1980'
  click_button 'continue'
end

And(/^I add the following people:$/) do |table|
  table.hashes.each do |row|
    fill_in 'key_person_first_name', with: row[:first_name]
    fill_in 'key_person_last_name', with: row[:last_name]
    fill_in 'key_person_dob_day', with: row[:dob_day]
    fill_in 'key_person_dob_month', with: row[:dob_month]
    fill_in 'key_person_dob_year', with: row[:dob_year]
    click_button 'add_btn'
  end
end

Then(/^I should see the following names listed:$/) do |table|
  table.hashes.each do |row|
    expect(page).to have_text row[:first_name]
    expect(page).to have_text row[:last_name]
  end
end

Then(/^I should only have to enter one key person$/) do
  expect(page).not_to have_button 'add_btn'
  expect(page).to have_button 'continue'
end

Then(/^I cannot proceed until I have added a key person$/) do
  click_button 'continue'
  expect(page).to have_text 'error'
  expect(page).not_to have_text 'Relevant'
end

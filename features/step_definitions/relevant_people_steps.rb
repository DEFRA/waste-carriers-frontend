Given(/^I am registering as an upper tier waste carrier$/) do
  step 'I have been funneled into the upper tier path'
  step 'I am a carrier dealer'
  step 'I provide my company name'
  step 'I autocomplete my business address'
  step 'I provide my personal contact details'
  step 'I enter the details of the business owner'
end

And(/^There are relevant people with relevant convictions in my organisation$/) do
  choose 'registration_declaredConvictions_yes'
  click_on 'Next'
end

And(/^I enter the following people with relevant convictions:$/) do |table|
  table.hashes.each do |row|
    fill_in 'key_person_first_name', with: row[:first_name]
    fill_in 'key_person_last_name', with: row[:last_name]
    fill_in 'key_person_position', with: row[:position]
    fill_in 'key_person_dob_day', with: row[:dob_day]
    fill_in 'key_person_dob_month', with: row[:dob_month]
    fill_in 'key_person_dob_year', with: row[:dob_year]
    click_on 'add_btn'
  end
end

Then(/^I cannot proceed until I have added a relevant person$/) do
  page.should_not have_button 'next_btn'
  page.should have_button 'add_btn'
end

And(/^I click next$/) do
  click_on 'Next'
end

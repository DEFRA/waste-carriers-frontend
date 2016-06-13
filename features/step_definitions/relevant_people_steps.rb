Given(/^I am registering as an upper tier waste carrier$/) do
  step 'I have been funneled into the upper tier path'
  step 'I am a carrier dealer'
  step 'I provide my company name'
  step 'I autocomplete my business address'
  step 'I provide my personal contact details'
  postal_address_page_complete_form
  step 'I enter the details of the business owner'
end

And(/^There are relevant people with relevant convictions in my organisation$/) do
  choose 'registration_declaredConvictions_yes'
  click_button 'continue'
end

And(/^I enter the following people with relevant convictions:$/) do |table|
  table.hashes.each do |row|
    fill_in 'key_person_first_name', with: row[:first_name]
    fill_in 'key_person_last_name', with: row[:last_name]
    fill_in 'key_person_position', with: row[:position]
    fill_in 'key_person_dob_day', with: row[:dob_day]
    fill_in 'key_person_dob_month', with: row[:dob_month]
    fill_in 'key_person_dob_year', with: row[:dob_year]
    click_button 'add_btn'
  end
end

Then(/^I cannot proceed until I have added a relevant person$/) do
  click_button 'continue'
  expect(page).to have_text 'error'
  expect(page).not_to have_text 'Check your details'
end

And(/^I click continue$/) do
  click_button 'continue'
end

Given(/^I am registering as a sole trader$/) do
  visit business_type_path
  choose 'registration_businessType_soletrader'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
  choose 'registration_isMainService_yes'
  click_button 'continue'
  choose 'registration_onlyAMF_no'
  click_button 'continue'
end

Given(/^I finish my convictions declaration$/) do
  click_button 'continue'
end

When(/^I choose to edit the conviction declaration$/) do
  click_link 'edit_conviction_declaration'
  choose 'registration_declaredConvictions_yes'
  click_button 'continue'
end

Given(/^I am registering as a Partnership$/) do
  visit business_type_path
  choose 'registration_businessType_partnership'
  click_button 'continue'
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
  choose 'registration_isMainService_yes'
  click_button 'continue'
  choose 'registration_onlyAMF_no'
  click_button 'continue'
end

 And(/^I am a broker dealer$/) do
   choose 'registration_registrationType_broker_dealer'
   click_button 'continue'
 end



Given(/^I edit my sole trader business owner details$/) do
  click_link 'edit_key_person'
  fill_in 'key_person_first_name', with: 'Jenson'
  fill_in 'key_person_last_name', with: 'Button'
  click_button 'continue'
end

When(/^I edit my business owner details$/) do
  click_link 'edit_key_person'
end

When(/^add another Partner$/) do
  fill_in 'key_person_first_name', with: 'Stirling'
  fill_in 'key_person_last_name', with: 'Moss'
  fill_in 'key_person_dob_day', with: '02'
  fill_in 'key_person_dob_month', with: '08'
  fill_in 'key_person_dob_year', with: '1900'
  click_button 'add_btn'
  click_button 'continue'
end

When('change another Partner') do
  click_link('Delete', match: :first)
  fill_in 'key_person_first_name', with: 'Stirling'
  fill_in 'key_person_last_name', with: 'Moss'
  fill_in 'key_person_dob_day', with: '02'
  fill_in 'key_person_dob_month', with: '08'
  fill_in 'key_person_dob_year', with: '1900'
  click_button 'add_btn'
  click_button 'continue'
end

Then('Delete first relevant person') do
  click_link('Delete', match: :first)
  click_button 'continue'
end

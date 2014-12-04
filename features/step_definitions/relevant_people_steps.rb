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
  click_on 'next_btn'
  page.should have_content 'error'
  page.should_not have_content 'Check your details'
end

And(/^I click next$/) do
  click_on 'Next'
end

Given(/^I am registering as a sole trader$/) do
  visit find_path
  choose 'registration_businessType_soletrader'
  click_on 'Next'
  choose 'registration_otherBusinesses_yes'
  click_on 'Next'
  choose 'registration_isMainService_yes'
  click_on 'Next'
  choose 'registration_onlyAMF_no'
  click_on 'Next'
end

Given(/^I finish my convictions declaration$/) do
  click_on 'next_btn'
end

When(/^I choose to edit the conviction declaration$/) do
  click_link 'Edit your conviction declaration'
end

Given(/^I am registering as a Partnership$/) do
  visit find_path
  choose 'registration_businessType_partnership'
  click_on 'Next'
  choose 'registration_otherBusinesses_yes'
  click_on 'Next'
  choose 'registration_isMainService_yes'
  click_on 'Next'
  choose 'registration_onlyAMF_no'
  click_on 'Next'
end

 And(/^I am a broker dealer$/) do
   choose 'registration_registrationType_broker_dealer'
   click_on 'Next'
 end
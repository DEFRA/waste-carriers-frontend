Given(/^I have completed the lower tier registration form$/) do
  visit business_type_path

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

  sleep 0.2 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
end

Given(/^I have been funneled into the lower tier path$/) do
  visit business_type_path

  choose 'registration_businessType_charity'
  click_on 'Next'
end

And(/^I provide my company name$/) do
  fill_in 'registration_companyName', with: 'Grades'
end

Given(/^I autocomplete my business address$/) do
  fill_in 'sPostcode', with: 'HP10 9BX'
  click_on 'Find UK address'
  #select '33 Fennels Way, Flackwell Heath HP10 9BX'
  select '33, FENNELS WAY, FLACKWELL HEATH, HIGH WYCOMBE, HP10 9BX'
  click_on 'Next'
end

Given(/^I want my business address autocompleted but I provide an unrecognised postcode$/) do
  fill_in 'sPostcode', with: my_unrecognised_postcode
end

Then(/^no address suggestions will be shown$/) do
  # Changed validation message
  page.should have_content 'Postcode is not valid'
  #page.should have_content 'There are no addresses for the given postcode'
end

When(/^I try to select an address$/) do
  click_on 'Find UK address'
end

Given(/^I enter my business address manually$/) do
  click_on 'I want to add an address myself'

  fill_in 'registration_companyName', with: 'Grades'
  fill_in 'registration_houseNumber', with: '44'
  fill_in 'registration_streetLine1', with: 'Broad Street'
  fill_in 'registration_streetLine2', with: 'City Centre'
  fill_in 'registration_townCity', with: 'Bristol'
  fill_in 'registration_postcode', with: 'BS1 2EP'

  click_on 'Next'
end

Given(/^I enter my foreign business address manually$/) do
  click_on 'I have an address outside the United Kingdom'

  fill_in 'registration_companyName', with: 'IWC'

  fill_in 'registration_streetLine1', with: 'Broad Street'
  fill_in 'registration_streetLine2', with: 'City Centre'
  fill_in 'registration_streetLine3', with: 'Bristol'
  fill_in 'registration_streetLine4', with: 'BS1 2EP'

  fill_in 'registration_country', with: 'France'

  click_on 'Next'
end

And(/^I provide my personal contact details$/) do
  fill_in 'registration_firstName', with: 'Joe'
  fill_in 'registration_lastName', with: 'Bloggs'
  fill_in 'registration_phoneNumber', with: '0117 926 8332'
  fill_in 'registration_contactEmail', with: my_email_address

  click_on 'Next'
end

And(/^I check the declaration$/) do
  check 'registration_declaration'

  click_on 'Confirm'
end

And(/^I provide my email address and create a password$/) do
  fill_in 'registration_accountEmail', with: my_email_address
  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password

  click_on 'Next'
end

When(/^I confirm account creation via email$/) do
  sleep 3.0 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
  open_email my_email_address
  #current_email.save_and_open      # Useful for debugging email content
  current_email.click_link 'confirmation_link'
end

Then(/^I am registered as a lower tier waste carrier$/) do
  page.should have_content 'you don’t need to pay a registration fee'
  open_email my_email_address
  current_email.should have_content 'Based on what you told us about your organisation and what it does, we have registered you as a lower tier waste carrier'
end

But(/^I can edit this postcode$/) do
  postcode_field = find_field('sPostcode')

  postcode_field.value.should == my_unrecognised_postcode
  postcode_field['disabled'].should_not be
end

And(/^add my address manually if I wanted to$/) do
  page.should have_link 'I want to add an address myself'
end

Given(/^I have gone through the lower tier waste carrier process$/) do
  visit business_type_path

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

  fill_in 'Confirm email', with: my_email_address
  fill_in 'Create password', with: my_password
  fill_in 'Confirm password', with: my_password
  click_on 'Next'

  sleep 0.1 # capybara-email recommends forcing a sleep prior to trying to read any email after an asynchronous event
end

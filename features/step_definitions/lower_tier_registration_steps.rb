Given(/^I have completed the lower tier registration form$/) do
  choose 'registration_businessType_soletrader'
  click_button 'continue'

  choose 'registration_otherBusinesses_no'
  click_button 'continue'

  choose 'registration_constructionWaste_no'
  click_button 'continue'

  click_link 'manual_uk_address'
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

  do_short_pause_for_email_delivery
end

Given(/^I have been funneled into the lower tier path$/) do
  choose 'registration_businessType_charity'
  click_button 'continue'
end

And(/^I provide my company name$/) do
  fill_in 'registration_companyName', with: 'Grades'
end

Given(/^I autocomplete my business address$/) do
  fill_in 'sPostcode', with: 'HP10 9BX'
  click_button 'find_address'
  select '33, FENNELS WAY, FLACKWELL HEATH, HIGH WYCOMBE, HP10 9BX'
  click_button 'continue'
end

Then(/^I see the OS places copyright message$/) do
  expect(page).to have_text 'Crown copyright and database rights 2016 Ordnance Survey 100024198'
end

Given(/^I want my business address autocompleted but I provide an unrecognised postcode$/) do
  fill_in 'sPostcode', with: my_unrecognised_postcode
end

Then(/^no address suggestions will be shown$/) do
  expect(page).to have_text 'No addresses match this postcode'
end

When(/^I try to select an address$/) do
  click_button 'find_address'
end

Given(/^I enter my business address manually$/) do
  click_link 'manual_uk_address'

  fill_in 'registration_companyName', with: 'Grades'
  fill_in 'address_houseNumber', with: '44'
  fill_in 'address_addressLine1', with: 'Broad Street'
  fill_in 'address_addressLine2', with: 'City Centre'
  fill_in 'address_townCity', with: 'Bristol'
  fill_in 'address_postcode', with: 'BS1 2EP'

  click_button 'continue'
end

Given(/^I enter my foreign business address manually$/) do
  click_link 'foreign_address'

  fill_in 'registration_companyName', with: 'IWC'

  fill_in 'address_addressLine1', with: '35, rue du Faubourg St Honoré '
  fill_in 'address_addressLine2', with: 'Paris Cedex 08'
  fill_in 'address_addressLine3', with: '75383'
  fill_in 'address_townCity', with: 'Paris'

  fill_in 'address_country', with: 'France'

  click_button 'continue'
end

And(/^I provide my personal contact details$/) do
  fill_in 'registration_firstName', with: 'Joe'
  fill_in 'registration_lastName', with: 'Bloggs'
  fill_in 'registration_phoneNumber', with: '0117 926 8332'
  fill_in 'registration_contactEmail', with: my_email_address

  click_button 'continue'
end

And(/^I provide a postal address$/) do
  postal_address_page_complete_form
end

And(/^I check the declaration$/) do
  check 'registration_declaration'

  click_button 'confirm'
end

And(/^I provide my email address and create a password$/) do
  fill_in 'registration_accountEmail', with: my_email_address
  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password

  click_button 'continue'
end

When(/^I confirm account creation via email$/) do
  do_short_pause_for_email_delivery
  open_email my_email_address
  current_email.click_link 'confirmation_link'
end

Then(/^I am registered as a lower tier waste carrier$/) do
  expect(page).to have_text 'you don’t need to pay a registration charge'
  open_email my_email_address
  expect(current_email).to have_text 'Based on what you told us about your '\
                                     'organisation and what it does, we have '\
                                     'registered you as a lower tier waste '\
                                     'carrier'
end

But(/^I can edit this postcode$/) do
  postcode_field = find_field('sPostcode')
  expect(postcode_field.value).to eq(my_unrecognised_postcode)
  expect(postcode_field).not_to be_disabled
end

And(/^add my address manually if I wanted to$/) do
  expect(page).to have_link 'I want to type the address myself'
end

Given(/^I have gone through the lower tier waste carrier process$/) do
  choose 'registration_businessType_soletrader'
  click_button 'continue'

  choose 'registration_otherBusinesses_no'
  click_button 'continue'

  choose 'registration_constructionWaste_no'
  click_button 'continue'

  click_link 'manual_uk_address'
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

  do_short_pause_for_email_delivery
end

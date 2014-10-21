Given(/^I am logged in as an NCCC agency user$/) do
  visit new_agency_user_session_path
  page.should have_content 'Sign in'
  page.should have_content 'Environment Agency login'
  fill_in 'Email', with: my_agency_user.email
  fill_in 'Password', with: my_agency_user.password
  click_button 'Sign in'
  page.should have_content "Signed in as agency user #{my_agency_user.email}"
end

Given(/^I start a new registration on behalf of a caller$/) do
  visit registrations_path
  click_on 'New registration'

  choose 'registration_newOrRenew_new'
  click_on 'Next'
end

Given(/^the caller provides initial answers for the lower tier$/) do
  choose 'registration_businessType_charity'
  click_on 'Next'
end

Given(/^the caller provides his business organisation details$/) do
  click_on 'I want to add an address myself'

  fill_in 'registration_companyName', with: 'Assisted Digital & Co'
  fill_in 'registration_houseNumber', with: '12'
  fill_in 'registration_streetLine1', with: 'Assisted Street'
  fill_in 'registration_streetLine2', with: 'Digital City Centre'
  fill_in 'registration_townCity', with: 'Bristol'
  fill_in 'registration_postcode', with: 'BS1 5AH'

  click_on 'Next'
end

Given(/^the caller provides his contact details$/) do
  fill_in 'registration_firstName', with: 'Antony'
  fill_in 'registration_lastName', with: 'Assisted'
  fill_in 'registration_phoneNumber', with: '0123 456 789'

  click_on 'Next'
end

Given(/^the caller declares the information provided is correct$/) do
  check 'registration_declaration'

  click_on 'Confirm'
end

Then(/^the registration confirmation email should not be sent$/) do
  # specifically "the registration confirmation email should not be sent *to the agency user" (for whom this is the only email address provided)
  open_email my_agency_user.email
  current_email.should be_nil
end

Then(/^the print page contains the six-digit access code for the user$/) do
  click_on 'view-certificate'

  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
end

When(/^I create a lower tier registration on behalf of a caller$/) do
  click_on 'New registration'

  choose 'registration_newOrRenew_new'
  click_on 'Next'

  choose 'registration_businessType_charity'
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
  click_on 'Next'

  check 'registration_declaration'
  click_on 'Confirm'

end

When(/^I create an upper tier registration on behalf of a caller$/) do
  click_on 'New registration'

  choose 'registration_newOrRenew_new'
  click_on 'Next'

  choose 'registration_businessType_soletrader'
  click_on 'Next'

  choose 'registration_otherBusinesses_yes'
  click_on 'Next'

  choose 'registration_isMainService_yes'
  click_on 'Next'

  choose 'registration_onlyAMF_no'
  click_on 'Next'

  choose 'registration_registrationType_carrier_dealer'
  click_on 'Next'

  click_on 'I want to add an address myself'
  fill_in 'registration_companyName', with: 'Assisted Enterprises & Co'
  fill_in 'registration_houseNumber', with: '123'
  fill_in 'registration_streetLine1', with: 'Deanery Road'
  fill_in 'registration_streetLine2', with: 'EA Building'
  fill_in 'registration_townCity', with: 'Bristol'
  fill_in 'registration_postcode', with: 'BS1 5AH'
  click_on 'Next'

  fill_in 'registration_firstName', with: 'Antony'
  fill_in 'registration_lastName', with: 'Assisted'
  fill_in 'registration_phoneNumber', with: '0123 456 789'
  click_on 'Next'

  step 'I enter the details of the business owner'

  choose 'No'
  click_on 'Next'

  check 'registration_declaration'
  click_on 'Confirm'
  click_on 'Pay by debit/credit card'
end

When(/^I create an upper tier registration on behalf of a caller who wants to pay offline$/) do
  click_on 'New registration'

  choose 'registration_newOrRenew_new'
  click_on 'Next'

  choose 'registration_businessType_soletrader'
  click_on 'Next'

  choose 'registration_otherBusinesses_yes'
  click_on 'Next'

  choose 'registration_isMainService_yes'
  click_on 'Next'

  choose 'registration_onlyAMF_no'
  click_on 'Next'

  choose 'registration_registrationType_carrier_dealer'
  click_on 'Next'

  click_on 'I want to add an address myself'
  fill_in 'registration_companyName', with: 'Assisted Enterprises & Co'
  fill_in 'registration_houseNumber', with: '123'
  fill_in 'registration_streetLine1', with: 'Deanery Road'
  fill_in 'registration_streetLine2', with: 'EA Building'
  fill_in 'registration_townCity', with: 'Bristol'
  fill_in 'registration_postcode', with: 'BS1 5AH'
  click_on 'Next'

  fill_in 'registration_firstName', with: 'Antony'
  fill_in 'registration_lastName', with: 'Assisted'
  fill_in 'registration_phoneNumber', with: '0123 456 789'
  click_on 'Next'

  step 'I enter the details of the business owner'

  choose 'No'
  click_on 'Next'

  check 'registration_declaration'
  click_on 'Confirm'

  click_on 'Pay by bank transfer'
end

And(/^the lower tier waste carrier registration id$/) do
  page.should have_content 'The registration number is: CBDL'
end

And(/^the upper tier waste carrier registration id/) do
  page.should have_content 'The registration number is: CBDU'
end

Then(/^I see the six\-character access code for the user$/) do
  page.should have_content 'The assisted digital access code is:'
end

And(/^I see the payment details to tell the customer$/) do
  click_on 'Next'
end

Then(/^I logout$/) do
  click_on 'signout_button'
  visit destroy_agency_user_session_path
end
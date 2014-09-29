Given(/^I have completed the upper tier and chosen to pay by bank transfer$/) do
  step 'I have been funneled into the upper tier path'
  step 'I am a carrier dealer'
  step 'I enter my business details'
  step 'I enter my contact details'
  step 'I enter the details of the business owner'
  step 'no key people in the organisation have convictions'
  step 'I confirm the declaration'
  step 'I enter new user account details'
  step 'I choose pay via electronic transfer'
end

Given(/^I have been funneled into the upper tier path$/) do
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

Given(/^I am a partnership on the upper tier path$/) do
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

And(/^I am a carrier dealer$/) do
  choose 'registration_registrationType_carrier_dealer'
  click_on 'Next'
end

And(/^I enter my business details$/) do
  fill_in 'registration_companyName', with: 'Bespoke'
  fill_in 'sPostcode', with: 'BS1 5AH'
  click_on 'Find UK address'

  select 'Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH'
  click_on 'Next'
end

And(/^I enter my contact details$/) do
  fill_in 'registration_firstName', with: 'Joe'
  fill_in 'registration_lastName', with: 'Bloggs'
  fill_in 'registration_phoneNumber', with: '0117 926 9999'
  fill_in 'registration_contactEmail', with: my_email_address
  click_on 'Next'
end

And(/^I confirm the declaration$/) do
  check 'registration_declaration'
  click_on 'Confirm'
end

Given(/^I enter new user account details$/) do
  fill_in 'registration_accountEmail', with: my_email_address
  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password

  click_on 'Next'
end

And(/^I choose pay via electronic transfer$/) do
  click_on 'Pay via electronic transfer'
  click_on 'Next'
end

Then(/^I am successfully registered as an upper tier waste carrier$/) do
  page.should have_content 'Signed in as'
  page.should have_content 'CBDU'
  page.should have_content 'ACTIVE'
  open_email my_email_address
  current_email.should have_content 'is registered as an upper tier waste carrier'
end

Then(/^I am registered as an upper tier waste carrier pending conviction checks$/) do
  page.should have_content 'Signed in as'
  page.should have_content 'CBDU'
  page.should have_content 'PENDING'
  open_email my_email_address
  current_email.should have_content 'Awaiting convictions' # Update this test once we have defined content for the convictions email
end

Then(/^I am registered as an upper tier waste carrier pending payment$/) do
  page.should have_content 'Signed in as'
  page.should have_content 'CBDU'
  page.should have_content 'PENDING'
  open_email my_email_address
  current_email.should have_content 'Awaiting payment'  # Update this test once we have defined content for the awaiting payment email
end

Then(/^I have applied as an upper tier waste carrier$/) do
  page.should have_content 'Signed in as'
  page.should have_content 'CBDU'
  page.should have_content 'PENDING'
end

Then(/^I have completed the application as an upper tier waste carrier via electronic transfer$/) do
  page.should have_content 'not yet registered as an upper tier waste carrier'
end

And(/^no key people in the organisation have convictions$/) do
  choose 'registration_declaredConvictions_no'
  click_on 'Next'
end

And(/^key people in the organisation have convictions$/) do
  choose 'Yes'
  click_on 'Next'
end

But(/^I am told my registration is pending a convictions check$/) do
  page.should have_content 'We are required to cross check the declared relevant people'
end
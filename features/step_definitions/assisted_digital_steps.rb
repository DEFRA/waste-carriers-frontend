Given(/^I am logged in as an NCCC agency user$/) do
  visit new_agency_user_session_path
  page.should have_content 'Sign in'
  page.should have_content 'NCCC agency login'
  fill_in 'Email', with: my_agency_user.email
  fill_in 'Password', with: my_agency_user.password
  click_button 'Sign in'
  page.should have_content "Signed in as agency user #{my_agency_user.email}"
end

Given(/^I start a new registration on behalf of a caller$/) do
  visit registrations_path
  click_button 'New registration'
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
  fill_in 'First name', with: 'Antony'
  fill_in 'Last name', with: 'Assisted'
  fill_in 'Job title', with: 'Chief'
  fill_in 'Phone number', with: '0123 456 789'

  click_on 'Next'
end

Given(/^the caller declares the information provided is correct$/) do
  check 'registration_declaration'

  click_on 'Confirm'
end

Given(/^the user confirms his account details$/) do
  click_on 'Next'
end


Then(/^the registration confirmation email should not be sent$/) do
  # specifically "the registration confirmation email should not be sent *to the agency user" (for whom this is the only email address provided)
  open_email my_agency_user.email
  current_email.should be_nil
end

Then(/^the print page contains the six-digit access code for the user$/) do
  click_on 'View certificate'

  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
end

When(/^I create a lower tier registration on behalf of a caller$/) do
  click_on 'New registration'

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

  fill_in 'First name', with: 'Joe'
  fill_in 'Last name', with: 'Bloggs'
  fill_in 'Job title', with: 'Chief Barber'
  fill_in 'Phone number', with: '0117 926 8332'
  fill_in 'Email address', with: my_email_address
  click_on 'Next'

  check 'registration_declaration'
  click_on 'Confirm'

  click_on 'Next'
end

When(/^I create an upper tier registration on behalf of a caller$/) do
  click_on 'New registration'

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

  fill_in 'First name', with: 'Antony'
  fill_in 'Last name', with: 'Assisted'
  fill_in 'Job title', with: 'Chief'
  fill_in 'Phone number', with: '0123 456 789'
  #Note: we want to leave the email address empty for assisted digital registrations - these may not have an email
  fill_in 'Email address', with: ''
  click_on 'Next'

  check 'registration_declaration'
  click_on 'Confirm'
  click_on 'Next'
  click_on 'Pay by debit/credit card'
end

When(/^I provide valid credit card payment details on behalf of a caller$/) do
  #Select MasterCard by clicking on the button:
  sleep 1.0

  page.should have_content 'Secure Payment Page'

  page.should have_content 'MasterCard'

  # Note TODO Click does not work, find a better way of identifying the input to click on?
  #click_button 'op-DPChoose-ECMC^SSL'
  first(:xpath, '/html/body/table/tbody/tr/td/table/tbody/tr[3]/td/table/tbody/tr[1]/td[2]/form/table/tbody/tr/td/table/tbody/tr[6]/td/table/tbody/tr[4]/td[1]/table/tbody/tr/td[2]/span/input').click

  #These are valid card numbers for the WorldPay Test Service. See the WorldPay XML Redirect Guide for details
  fill_in 'cardNoInput', with: '4444333322221111'
  fill_in 'cardCVV', with: '123'
  select('12', from: 'cardExp.month')
  select('2015', from: 'cardExp.year')
  fill_in 'name', with: 'Mr Waste Carrier'
  fill_in 'address1', with: 'Upper Waste Carrier Street'
  fill_in 'town', with: 'Upper Town'
  fill_in 'postcode', with: 'BS1 5AH'
  click_on 'op-PMMakePayment'

  sleep 1.0
  #By now we should be on the Test Simulator page...
  page.should have_content 'Secure Test Simulator Page'
  #The standard 'approved' etc. should already be selected, just click the 'continue' button (input)
  #click_on 'continue'
  first(:xpath,'/html/body/table/tbody/tr/td/table/tbody/tr[3]/td/table/tbody/tr[1]/td[2]/form/table/tbody/tr/td/table/tbody/tr[6]/td/label/nobr/input').click

  # This is the 'Continue' link on our provisional Worldpay Success page.
  # Later this should redirect automatically to another page showing the payment confirmation.
  click_on 'Continue'

  # TODO at this point we ought to be on page with access code but are at confirmation page
end

And(/^the lower tier waste carrier registration id$/) do
  page.should have_content 'Your registration number is: CBDL'
end

And(/^the upper tier waste carrier registration id/) do
  page.should have_content 'Your registration number is: CBDU'
end

Then(/^I see the six\-character access code for the user$/) do
  page.should have_content 'Your access code is:'
end
#
# The following is sample fill_in content
#
#  fill_in 'Email', with: my_user.email
#  fill_in 'Password', with: my_user.password
#  click_button 'Sign in'
#

# This counter is to log the number of uniquely created registrations for the payment scenarios
registrationCount = 0

Given(/^I am logged in as a finance admin user$/) do
  visit new_agency_user_session_path
  page.should have_content 'Sign in'
  page.should have_content 'NCCC agency login'
  fill_in 'Email', with: my_finance_admin_user.email
  fill_in 'Password', with: my_finance_admin_user.password
  click_button 'Sign in'
  page.should have_content "Signed in as agency user #{my_finance_admin_user.email}"
end

Given(/^I am logged in as a finance basic user$/) do
  visit new_agency_user_session_path
  page.should have_content 'Sign in'
  page.should have_content 'NCCC agency login'
  fill_in 'Email', with: my_finance_basic_user.email
  fill_in 'Password', with: my_finance_basic_user.password
  click_button 'Sign in'
  page.should have_content "Signed in as agency user #{my_finance_basic_user.email}"
end

Given(/^I am logged in as a nccc refunds user$/) do
  visit new_agency_user_session_path
  page.should have_content 'Sign in'
  page.should have_content 'NCCC agency login'
  fill_in 'Email', with: my_agency_refund_user.email
  fill_in 'Password', with: my_agency_refund_user.password
  click_button 'Sign in'
  page.should have_content "Signed in as agency user #{my_agency_refund_user.email}"
end

Given(/^I have found a registrations payment details$/) do
  visit registrations_path
  page.should have_content 'Find a registration'
  fill_in 'q', with: 'PaymentReg'+registrationCount.to_s
  click_button 'Search'
  find_button('paymentStatus1').click
  page.should have_content 'Payment status'
end

Given(/^the registration is valid for a small write off$/) do
  # Here we am running a series of steps to get the registraiton in the state ready for a small write off
  # A payment of 100.00 puts the excess balance of 54 within the 0-100 (Payment.basicMinimum-Payment.basicMaximum) 
  # range of the small write off
  steps %Q{
    Given I select to enter payment
    And I enter 100.00
    And I enter payment details
    And I confirm payment
  }
end

Given(/^I provided a payment type of Cheque$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I provided a payment type of Cash$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I provided a payment type of Postal Order$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I select to enter payment$/) do
  page.should have_content 'Payment status'
  click_link 'enterPayment'
  page.should have_content 'Enter payment'
end

When(/^I select to enter a large writeoff$/) do
  page.should have_content 'Payment status'
  click_link 'writeOffLarge'
  page.should have_content 'Write off difference'
end

When(/^I select to enter a small writeoff$/) do
  page.should have_content 'Payment status'
  click_link 'writeOffSmall'
  page.should have_content 'Write off difference'
end

When(/^I pay the full amount owed$/) do
  page.should have_content 'Awaiting payment'
  amountSummary = page.find_by_id 'amountSummary'
  amountDue = page.find_by_id 'amountDue'
  amountDueWithout = amountDue.text.delete '£'
  amountSummary.text.should == 'Awaiting payment £' + amountDueWithout
  fill_in 'payment_amount', with: amountDueWithout.to_s
end

When(/^I writeoff equal to underpayment amount$/) do
  page.should have_content 'Amount to write off'
  amountSummary = page.find_by_id 'amountSummary'
  amountDue = page.find_by_id 'amountDue'
  amountDueWithout = amountDue.text.delete '£'
  amountSummary.text.should == 'Amount to write off £' + amountDueWithout
  fill_in 'payment_registrationReference', with: 'MYTESTREFERENCE'
end

When(/^I enter payment details$/) do
  fill_in 'payment_dateReceived_day', with: '24'
  fill_in 'payment_dateReceived_month', with: '07'
  fill_in 'payment_dateReceived_year', with: '2014'
  fill_in 'payment_registrationReference', with: 'MYTESTREFERENCE'
end

When(/^I confirm payment$/) do
  click_on 'Enter Payment'
end

When(/^I confirm write off$/) do
  click_on 'Write off'
end

Then(/^payment history will be updated$/) do
  page.should have_content 'MYTESTREFERENCE'
end

When(/^balance is (\d+)$/) do |arg1|
  page.should have_content 'Awaiting payment £'+arg1
end

When(/^I enter (\d+)$/) do |arg1|
  fill_in 'payment_amount', with: arg1
end

When(/^I enter (\d+)\.(\d+)$/) do |arg1, arg2|
  totalVal = arg1 + '.' + arg2
  fill_in 'payment_amount', with: totalVal
end

Then(/^payment balance will be (\d+)\.(\d+)$/) do |arg1, arg2|
  balanceDue = page.find_by_id 'balanceDue'
  totalVal = arg1 + '.' + arg2
  balanceDue.text.should == totalVal
end


Then(/^payment status will be paid$/) do
  page.should have_content 'Paid in full'
  page.should have_content 'Payment has been successfully entered'
end

When(/^payment status is paid$/) do
  page.should have_content 'Paid in full'
  page.should have_content 'Payment has been successfully entered'
end

Then(/^payment status will be pending$/) do
  page.should have_content 'Awaiting payment'
end

When(/^payment status is pending$/) do 
  page.should have_content 'Awaiting payment'
end

Then(/^payment status will be overpaid$/) do
  page.should have_content 'Overpaid'
end

When(/^payment balance is underpaid$/) do
  page.should have_content 'Awaiting payment'
end

When(/^renewal charge changes$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^payment balance will not change$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^registration charge changes$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I enter negative payment amount$/) do
  pending
  #
  # FIXME: Currently the enter payment screen does allow negative inputs from the user, not sure if this is a bad test or not?
  #
#  fill_in 'payment_amount', with: ''
end

Then(/^the system will reject payment$/) do
  page.should have_content 'Enter payment'
end

Given(/^I am authenticated as a finance refunds user$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^balance is in credit$/) do
  page.should_not have_content 'Awaiting payment'
end

When(/^refund is selected$/) do
  page.should have_content 'Payment status'
  click_link 'refund'
  page.should have_content 'Refunds'
end

Then(/^refund is made against original payment card$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^refunder name will be recorded$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^original payment method was via BACS$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^refund is rejected$/) do
  page.should have_content 'Refunds'
  page.should have_content 'No Payment History'
end

When(/^original payment method was via Cheque$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^original payment method was via Cash$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^original payment method was via Postal Order$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^original payment method was via Worldpay$/) do
  page.should have_content 'WORLDPAY'
end

When(/^balance is not in credit$/) do
#  pending
#
# Commenting out test as this is currently a bug.
#
  page.should have_content 'Awaiting payment'
end

When(/^refund amount is greater than original payment amount$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I don't have refund user role$/) do
  pending # express the regexp above with the code you wish you had
end

#
# This helper function is usefull for debugging pages, 
# alternatively just call the containing save_and_open_page line 
# from within a step
#
Then /^show me the page$/ do
  save_and_open_page
end

#
# This is a copy from assisted_digital_steps.rb line 95 
# When(/^I create an upper tier registration on behalf of a caller$/) do
# But has a unique companyName, such that each payment scenario can find and use a unique registration.
# And increments a registration count
#
When(/^I create an upper tier registration on behalf of a caller for payments$/) do

  # Increment registration count
  registrationCount = registrationCount + 1

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
  fill_in 'registration_companyName', with: 'PaymentReg'+registrationCount.to_s
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
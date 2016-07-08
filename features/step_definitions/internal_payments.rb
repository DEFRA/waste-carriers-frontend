# Helper functions to retry the search after waiting a period of time to
# ensure the system has been updated correctly
def waitForSearchResultToPassLambda(searchParam, test)
  total_wait_time = 0
  loop do
    fill_in 'q', with: searchParam
    click_button 'reg-search'
    break if test.call(page) || (total_wait_time > 20)
    puts '... Waiting 1 second before re-trying search '\
         '(maximum wait time is 20 seconds)'
    sleep 1
    total_wait_time += 1
  end
end

def waitForSearchResultsToContainElementWithId(searchParam, elementIdToWaitFor)
  xpath_to_wait_for = "//*[@id = '#{elementIdToWaitFor}']"
  waitForSearchResultToPassLambda(
    searchParam,
    lambda {|page| page.has_xpath?(xpath_to_wait_for) })
  expect(page).to have_xpath xpath_to_wait_for
end

def waitForSearchResultsToContainText(searchParam, textToWaitFor)
  waitForSearchResultToPassLambda(
    searchParam,
    lambda {|page| page.has_text?(textToWaitFor) })
  expect(page).to have_text textToWaitFor
end

#
# The following is sample fill_in content
#
#  fill_in 'Email', with: my_user.email
#  fill_in 'Password', with: my_user.password
#  click_button 'sign_in'
#

# This counter is to log the number of uniquely created registrations for the payment scenarios
registrationCount = 0

Given(/^I am logged in as a finance admin user$/) do
  visit new_agency_user_session_path
  expect(page).to have_text 'Sign in'
  expect(page).to have_text 'Environment Agency login'
  fill_in 'Email', with: my_finance_admin_user.email
  fill_in 'Password', with: my_finance_admin_user.password
  click_button 'sign_in'
  expect(page).to have_xpath("//*[@id = 'agency-user-signed-in']")
end

Given(/^I am logged in as a finance basic user$/) do
  visit new_agency_user_session_path
  expect(page).to have_text 'Sign in'
  expect(page).to have_text 'Environment Agency login'
  fill_in 'Email', with: my_finance_basic_user.email
  fill_in 'Password', with: my_finance_basic_user.password
  click_button 'sign_in'
  expect(page).to have_xpath("//*[@id = 'agency-user-signed-in']")
end

Given(/^I am logged in as a nccc refunds user$/) do
  visit new_agency_user_session_path
  expect(page).to have_text 'Sign in'
  expect(page).to have_text 'Environment Agency login'
  fill_in 'Email', with: my_agency_refund_user.email
  fill_in 'Password', with: my_agency_refund_user.password
  click_button 'sign_in'
  expect(page).to have_xpath("//*[@id = 'agency-user-signed-in']")
end

Given(/^I change user to a nccc refunds user$/) do
  click_button 'Sign out'
  visit '/agency_users/sign_in'
  expect(page).to have_text 'Sign in'
  expect(page).to have_text 'Environment Agency login'
  fill_in 'Email', with: my_agency_refund_user.email
  fill_in 'Password', with: my_agency_refund_user.password
  click_button 'sign_in'
  expect(page).to have_xpath("//*[@id = 'agency-user-signed-in']")
end

Given(/^I have found a registrations payment details$/) do
  visit registrations_path
  expect(page).to have_text 'Registration search'
  waitForSearchResultsToContainElementWithId('PaymentReg'+registrationCount.to_s, 'searchResult1')
  click_link('paymentStatus1')
  expect(page).to have_text 'Payment status'
end

Given(/^I have found a registrations payment details using the remembered id$/) do
  visit registrations_path
  expect(page).to have_text 'Registration search'
  waitForSearchResultsToContainElementWithId(@stored_value.to_s, 'searchResult1')
  click_link('paymentStatus1')
  expect(page).to have_text 'Payment status'
end

Given(/^I have found a registrations payment details by name: (.*)$/) do |param|
  visit registrations_path
  expect(page).to have_text 'Registration search'
  waitForSearchResultsToContainElementWithId(param.to_s, 'searchResult1')
  click_link('paymentStatus1')
  expect(page).to have_text 'Payment status'
end

Then(/^searching for registration '(.*)' confirms its status is now '(.*)'$/) do |searchTerm, expectedStatusText|
  visit registrations_path
  expect(page).to have_text 'Registration search'
  waitForSearchResultsToContainText(searchTerm, 'Status ' + expectedStatusText)
end

Then(/^I am redirected to agency user home page with no fee$/) do
  expect(page).to have_text 'Registration search'
  expect(page).to have_text 'You can search for a registration by'
end

Then(/^I am redirected to account holder home page with no fee$/) do
  expect(page).to have_text 'Your waste carrier registrations'
  expect(page).to have_text 'These are the registrations linked to your account.'
end

Given(/^the registration is valid for a small write off$/) do
  # Here we am running a series of steps to get the registraiton in the state ready for a small write off
  # A payment of 150.00 puts the excess balance of 4 within the -5->5 (Payment.basicMinimum-Payment.basicMaximum)
  # range of the small write off
  steps %Q{
    Given I select to enter payment
    And I enter 150.00
    And I enter payment details
    And I confirm payment
  }
end

Given(/^I sign out$/) do
#  save_and_open_page
  click_button 'sign_out'
#  save_and_open_page
#  visit new_agency_user_session_path
#  expect(page).to have_text 'Sign in'
#  save_and_open_page
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
  expect(page).to have_text 'Payment status'
  click_link 'enterPayment'
  expect(page).to have_text 'Enter payment'
end

When(/^I select to enter a large writeoff$/) do
  expect(page).to have_text 'Payment status'
  click_link 'writeOffLarge'
  expect(page).to have_text 'Write off difference'
end

When(/^I select to enter a small writeoff$/) do
  expect(page).to have_text 'Payment status'
  click_link 'writeOffSmall'
  expect(page).to have_text 'Write off difference'
end

When(/^I pay the full amount owed$/) do
  expect(page).to have_text 'Awaiting payment'
  amount_summary = page.find_by_id 'amountSummary'
  amount_due = page.find_by_id 'amountDue'
  amount_due_without = amount_due.text.delete '£'
  expect(amount_summary).to have_text "Awaiting payment £#{amount_due_without}"
  fill_in 'payment_amount', with: amount_due_without.to_s
end

When(/^I writeoff equal to underpayment amount$/) do
  expect(page).to have_text 'Amount to write off'
  amount_due = page.find_by_id 'amountDue'
  amount_due = (amount_due.text.delete '£').to_i
  expect(amount_due).to be > 0
end

When(/^I enter payment details$/) do
  fill_in 'payment_dateReceived_day', with: '24'
  fill_in 'payment_dateReceived_month', with: '07'
  fill_in 'payment_dateReceived_year', with: '2014'
  fill_in 'payment_registrationReference', with: 'MYTESTREFERENCE'
end

When(/^I confirm payment$/) do
  click_button 'enter_payment_btn'
end

When(/^I confirm write off$/) do
  click_button 'write_off'
end

Then(/^payment history will be updated$/) do
  expect(page).to have_text 'MYTESTREFERENCE'
end

Then(/^payment history will show writeoff$/) do
  expect(page).to have_text 'Large Write off'
end

When(/^balance is (\d+)$/) do |arg1|
  expect(page).to have_text 'Awaiting payment £' + arg1
end

When(/^I enter (\d+)$/) do |arg1|
  fill_in 'payment_amount', with: arg1
end

When(/^I enter (\d+)\.(\d+)$/) do |arg1, arg2|
  total_val = arg1 + '.' + arg2
  fill_in 'payment_amount', with: total_val
end

Then(/^payment balance will be (\d+)\.(\d+)$/) do |arg1, arg2|
  balance_due = page.find_by_id 'balanceDue'
  total_val = arg1 + '.' + arg2
  expect(balance_due).to have_text total_val
end


Then(/^payment status will be paid$/) do
  expect(page).to have_text 'Paid in full'
  expect(page).to have_text 'has been successfully entered'
end

When(/^payment status is paid$/) do
  expect(page).to have_text 'Paid in full'
  expect(page).to have_text 'Payment has been successfully entered'
end

Then(/^payment status will be pending$/) do
  expect(page).to have_text 'Awaiting payment'
end

When(/^payment status is pending$/) do
  expect(page).to have_text 'Awaiting payment'
end

Then(/^payment status will be overpaid$/) do
  expect(page).to have_text 'Overpaid'
end

When(/^payment balance is underpaid$/) do
  expect(page).to have_text 'Awaiting payment'
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
  # fill_in 'payment_amount', with: ''
end

Then(/^the system will reject payment$/) do
  expect(page).to have_text 'Enter payment'
end

Given(/^I am authenticated as a finance refunds user$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^balance is in credit$/) do
  expect(page).not_to have_text 'Awaiting payment'
end

And(/^refund is selected$/) do
  expect(page).to have_text 'Payment status'
  click_link 'refund'
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
  expect(page).to have_text 'Payment status'
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
  expect(page).to have_text 'Worldpay'
end

When(/^balance is not in credit$/) do
#  pending
#
# Commenting out test as this is currently a bug.
#
  expect(page).to have_text 'Awaiting payment'
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

  registrationCount = rand(1..1000)

  click_link 'new_registration'

  choose 'registration_newOrRenew_new'
  click_button 'continue'

  choose 'registration_businessType_soletrader'
  click_button 'continue'

  choose 'registration_otherBusinesses_yes'
  click_button 'continue'

  choose 'registration_isMainService_yes'
  click_button 'continue'

  choose 'registration_onlyAMF_no'
  click_button 'continue'

  choose 'registration_registrationType_carrier_dealer'
  click_button 'continue'

  click_link 'manual_uk_address'

  # Needs a sleep here for some reason?, without it, companyName is not filled in generating required error
  sleep 1

  fill_in 'registration_companyName', with: 'PaymentReg'+registrationCount.to_s
  fill_in 'address_houseNumber', with: '123'
  fill_in 'address_addressLine1', with: 'Deanery Road'
  fill_in 'address_addressLine2', with: 'EA Building'
  fill_in 'address_townCity', with: 'Bristol'
  fill_in 'address_postcode', with: 'BS1 5AH'
  click_button 'continue'

  fill_in 'registration_firstName', with: 'Antony'
  fill_in 'registration_lastName', with: 'Assisted'
  fill_in 'registration_phoneNumber', with: '0123 456 789'
  click_button 'continue'

  postal_address_page_complete_form

  step 'I enter the details of the business owner'

  choose 'No'
  click_button 'continue'

  check 'registration_declaration'
  click_button 'confirm'

  choose 'registration_payment_type_world_pay'
  click_button 'proceed_to_payment'
end

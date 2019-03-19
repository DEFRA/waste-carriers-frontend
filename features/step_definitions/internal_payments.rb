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

When("balance is {int}") do |expected_balance|
  expect(page).to have_text "Awaiting payment £#{expected_balance}"
end

When("I enter {int}") do |payment|
  fill_in 'payment_amount', with: payment
end

When("I enter {float}") do |payment|
  fill_in 'payment_amount', with: payment
end

Then("payment balance will be {float}") do |expected_balance|
  balance_due = page.find_by_id 'balanceDue'
  expect(balance_due).to have_text expected_balance.to_s
end

Then(/^payment status will be paid$/) do
  expect(page).to have_text 'Paid in full'
  expect(page).to have_text 'has been successfully entered'
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

And(/^refund is selected$/) do
  expect(page).to have_text 'Payment status'
  click_link 'refund'
end

Then(/^refund is rejected$/) do
  expect(page).to have_text 'Payment status'
end

When(/^balance is not in credit$/) do
#  pending
#
# Commenting out test as this is currently a bug.
#
  expect(page).to have_text 'Awaiting payment'
end

Given(/^I partially complete an Upper Tier registration, but stop at the payment page$/) do
  step 'I have been funneled into the upper tier path'
  step 'I am a carrier dealer'
  step 'I enter my business details'
  step 'I enter my contact details'
  postal_address_page_complete_form
  step 'I enter the details of the business owner'
  step 'no key people in the organisation have convictions'
  step 'I confirm the declaration'
  step 'I enter new user account details'
end

Given(/^I partially complete an IR Renewal registration, but stop at the payment page$/) do
  repopulate_database_with_IR_data
  visit start_path
  choose 'registration_newOrRenew_renew'
  click_button 'continue'
  fill_in 'registration_originalRegistrationNumber', with: 'CB/AN9999YY/R002'
  click_button 'continue'

  step 'I have been funneled into the upper tier path'
  step 'I am a carrier dealer'
  step 'I enter my business details'
  step 'I enter my contact details'
  postal_address_page_complete_form
  step 'I enter the details of the business owner'
  step 'no key people in the organisation have convictions'
  step 'I confirm the declaration'
  step 'I enter new user account details'
end

When('I start a new browser session') do
  Capybara.reset_sessions!
  # sleep 0.5 # TODO: Remove this hack; seems to be a timing issue somewhere.
end

When ('complete the registration as a normal user via the WorldPay route') do
  visit new_user_session_path
  fill_in 'Email', with: my_email_address
  fill_in 'Password', with: my_password
  click_button 'sign_in'

  expect(page).to have_text 'You have 1 registration'
  click_link('edit_CBDU1')

  expect(page).to have_text 'Check your details before registering'
  step 'I confirm the declaration'
  step 'I pay by card'
end

Then ('I log in to my account and edit my registration') do
  visit new_user_session_path
  fill_in 'Email', with: my_email_address
  fill_in 'Password', with: my_password
  click_button 'sign_in'
  expect(page).to have_text 'You have 1 registration'
  click_link('edit_CBDU1')
  expect(page).to have_text 'Check your details before registering'

end




When('sign in as an NCCC Finance Admin') do
  visit new_agency_user_session_path
  fill_in 'Email', with: my_finance_admin_user.email
  fill_in 'Password', with: my_finance_admin_user.password
  click_button 'sign_in'
  expect(page).to have_selector(:id, 'agency-user-signed-in')
end

When('view the Payment Status for the registraiton') do
  waitForSearchResultsToContainText(my_company_name, 'Found 1 registration')
  click_link('paymentStatus1')
  expect(page).to have_text('Charge history')
end

When ('I enter a payment for the full ammount owed') do
  click_link('enterPayment')
  expect(page).to have_text 'Awaiting payment'
  amount_due = page.find_by_id('amountDue').text.delete('£')
  fill_in 'payment_amount', with: amount_due
  fill_in 'payment_dateReceived_day', with: Date.today.mday.to_s
  fill_in 'payment_dateReceived_month', with: Date.today.month.to_s
  fill_in 'payment_dateReceived_year', with: Date.today.year.to_s
  fill_in 'payment_registrationReference', with: 'test'
  click_button('enter_payment_btn')
end

Then(/^the registration (should|should not) appear on the public register$/) do |mode|
  if (mode == 'should not')
    search_page_check_search_result_negative(my_company_name)
  else
    search_page_check_search_result_positive(my_company_name)
  end
end

Then (/^the Charge History should contain the text "(.*)"$/) do |expected_text|
  within(:xpath, '//table[@id="charge_history_table"]') do
    expect(page).to have_text expected_text
    expect(page).to_not have_text 'default item'
  end
end

Then (/^the Balance should be £(\d+\.\d\d)$/) do |expected_balance|
  within(:xpath, "//table[@id='balance_table']") do
    expect(page).to have_text expected_balance
  end
end

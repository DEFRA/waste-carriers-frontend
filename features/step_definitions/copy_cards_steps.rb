Given(/^I log in as a Public body$/) do
 sign_in_page_sign_in_as_public_body_and_submit
end

Given(/^I have selected copy cards option for that registration$/) do
 user_registrations_page_add_copy_cards
end

Given(/^I have chosen 3 copy cards$/) do 
  # fill_in 'registration_copy_cards', with: 3
  your_registration_order_page_enter_copy_cards
end

Then(/^I can choose to pay by card or electronic transfer$/) do
  page.has_button?('continue')
  page.has_button?('offline_continue')
end

Given(/^I choose to pay by credit card$/) do
  your_registration_order_page_pay_by_credit_card
end

Given(/^I choose to pay by Mastercard$/) do
  waitForWorldpayToLoad
  secure_payment_page_pay_by_mastercard
end

Given(/^I can confirm the amount charged is correct$/) do
  secure_payment_details_page_check_amount(amount: '15.00')
end

When(/^I submit my Mastercard detals$/) do
  secure_payment_details_page_enter_mastercard_details_and_submit
  secure_test_simulator_page_continue
end

When /^I will be prompted to fill in "([^"]*)" with "([^"]*)"$/ do |element, text|
  fill_in element, with: text
end

Given(/^I'm on the copy cards payment summary page$/) do
  page.should have_content 'Copy cards'
end

Then(/^I will be shown confirmation of paid order$/) do
  payment_copy_cards_complete_check_order
end

Then(/^I will be shown confirmation of unpaid order$/) do
  # Payment Checks
  page.should have_content 'Almost there'
  # Content specific checks
  page.should have_content 'Thank you for your copy card order'

  click_on 'Finish'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'

end

Then(/^I finish my registration$/) do
  # Perform this as it cleans the session variables
  click_on 'Finish'
end

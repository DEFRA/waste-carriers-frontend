Given(/^I log in as a Public body waste carrier$/) do
 sign_in_page_sign_in_as_public_body_and_submit
end

Given(/^I order and pay for 3 cards with Mastercard$/) do
 user_registrations_page_add_copy_cards
 your_registration_order_page_enter_copy_cards
 your_registration_order_page_pay_by_credit_card
  waitForWorldpayToLoad
  secure_payment_page_pay_by_mastercard
  secure_payment_details_page_check_worldpay_amount(amount: '15.00')
    secure_payment_details_page_enter_mastercard_details_and_submit
  secure_test_simulator_page_continue
end

When /^I order "(.*?)" of copy cards and choose to pay offline$/ do |text|
  your_registration_order_page_enter_copy_cards(no_of_cards: text.to_i)
  your_registration_order_page_pay_by_bank_transfer
end

Given(/^I choose to order copy cards for my registration$/) do
  user_registrations_page_add_copy_cards
  end

Then(/^I will be shown confirmation of paid order$/) do
  payment_copy_cards_complete_check_order
end

Then(/^the total amount is "(.*?)"$/) do |amount|
secure_payment_details_page_check_bank_transfer_amount(amount: amount)
end


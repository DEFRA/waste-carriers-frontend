Feature: Refunds via Worldpay
As an authorised refunds user
I want to be able to refund waste carriers overpayment electronically
so that it's easy to repay overpayment

Unique worldpay reference is passed to Worldpay along the card details when a payment is made. The system will provide Worldpay with this reference when a refund is required, enabling the refund transaction to be made against the card used for the original payment.

Background:
Given I am logged in as a nccc refunds user
#  And I create an upper tier registration on behalf of a caller for payments
#  And I provide valid credit card payment details on behalf of a caller
#  And I have found a registrations payment details

@happy_days
Scenario: Refund via worldpay
Given I create an upper tier registration on behalf of a caller for payments
  And I provide valid credit card payment details on behalf of a caller
  And I have found a registrations payment details
When original payment method was via Worldpay
And balance is in credit
And refund is selected
Then refund is made against original payment card
And payment history will be updated
And refunder name will be recorded

Scenario Outline: Original payment from other payment method
Given I create an upper tier registration on behalf of a caller for payments
  And I provided a payment type of <payment_method>
  And I have found a registrations payment details
When original payment method was via <payment_method>
And balance is in credit
And refund is selected
Then refund is rejected

Examples:
|	payment_method	|
|	Postal Order	|
|	Cheque			|
|	Cash			|

Scenario: Refund rejected when balance is not in credit
Given I create an upper tier registration on behalf of a caller for payments
  And I have found a registrations payment details
  And balance is not in credit
  And refund is selected
  Then refund is rejected

Scenario: Refund rejected when payment amount is greater than original amount
Given I create an upper tier registration on behalf of a caller for payments
  And I provide valid credit card payment details on behalf of a caller
  And I have found a registrations payment details
When original payment method was via Worldpay
And balance is in credit
And refund is selected
But refund amount is greater than original payment amount
Then refund is rejected


#
# This scenario is flawed given the current feature background rules that a nccc refund user is logged in
# If this test is to exist a different user without that role should be signed in.
#
#Scenario: Refund by non finance refunds user
#Given I create an upper tier registration on behalf of a caller for payments
#  And I provide valid credit card payment details on behalf of a caller
#  And I have found a registrations payment details
#When original payment method was via Worldpay
#And balance is in credit
#And refund is selected
#But I don't have refund user role
#Then refund is rejected



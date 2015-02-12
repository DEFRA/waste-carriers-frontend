Feature: Refunds via Worldpay

  As an authorised refunds user
  I want to be able to refund waste carriers overpayment electronically
  so that it's easy to repay overpayment
  Unique worldpay reference is passed to Worldpay along the card details when a payment is made. The system will provide Worldpay with this reference when a refund is required, enabling the refund transaction to be made against the card used for the original payment.

Background:
  Given I am logged in as a nccc refunds user

@javascript @happy_days
Scenario: Refund via worldpay
  Given I create an upper tier registration on behalf of a caller for payments
  And I provide valid credit card payment details on behalf of a caller
  And I remember the registration id
  And I have found a registrations payment details using the remembered id
  When original payment method was via Worldpay
  And balance is in credit
  And refund is selected

Scenario: Refund rejected when balance is not in credit
  Given I create an upper tier registration on behalf of a caller who wants to pay offline
  And I make a note of the details
  And I finish the registration
  And I logout
  And I am logged in as a nccc refunds user
  And I have found a registrations payment details by name: Assisted Enterprises & Co
  And balance is not in credit
  And refund is selected
  Then refund is rejected

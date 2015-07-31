Feature: Handling of registrations that drop-off at payment

Scenario: New upper tier registration that drops-off at payment, with later offline payment.
  Given I partially complete an Upper Tier registration, but stop at the payment page
    And I have confirmed my email address
   When I start a new browser session
   Then the registration should not appear on the public register
   When I start a new browser session
    And sign in as an NCCC Finance Admin
    And view the Payment Status for the registraiton
   Then the Charge History should contain the text "Initial Registration"
    And the Balance should be £154.00
   When I enter a payment for the full ammount owed
   Then the Balance should be £0.00
   When I start a new browser session
   Then the registration should appear on the public register

@javascript
Scenario: IR renewal registration that drops-off at payment, with later online payment.
  Given I partially complete an IR Renewal registration, but stop at the payment page
    And I have confirmed my email address
   When I start a new browser session
   Then the registration should not appear on the public register
   When I start a new browser session
    And sign in as an NCCC Finance Admin
    And view the Payment Status for the registraiton
   Then the Charge History should contain the text "Renewal of Registration"
    And the Balance should be £105.00
   When I start a new browser session
    And complete the registration as a normal user via the WorldPay route
   When I start a new browser session
    And sign in as an NCCC Finance Admin
    And view the Payment Status for the registraiton
   Then the Balance should be £0.00
   When I start a new browser session
   Then the registration should appear on the public register
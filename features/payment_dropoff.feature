Feature: Handling of registrations that drop-off at payment

Scenario: New upper tier registration that drops-off at payment, with later offline payment.
  Given PENDING: I partially complete an Upper Tier registration, but stop at the payment page
    And I have confirmed my email address
   When I start a new browser session
   When I start a new browser session
    And sign in as an NCCC Finance Admin
    And view the Payment Status for the registration
   Then the Charge History should contain the text "Initial Registration"
    And the Balance should be £154.00
   When I enter a payment for the full ammount owed
   Then the Balance should be £0.00
   When I start a new browser session

@javascript
Scenario: IR renewal registration that drops-off at payment, with later online payment.
  Given PENDING: I partially complete an IR Renewal registration, but stop at the payment page
    And I have confirmed my email address
   When I start a new browser session
   When I start a new browser session
    And sign in as an NCCC Finance Admin
    And view the Payment Status for the registration
   Then the Charge History should contain the text "Renewal of Registration"
    And the Balance should be £105.00
   When I start a new browser session
    And complete the registration as a normal user via the WorldPay route
   When I start a new browser session
    And sign in as an NCCC Finance Admin
    And view the Payment Status for the registration
   Then the Balance should be £0.00
   When I start a new browser session

Scenario: As a User I want to be able to renew my registration up to the point
  where my account is created and I am presented with the Payment Summary page
  which shows the renewal fee of 105.00. I then kill my session and return by login in
  and competing the registration ensuring I have a renewal Fee of 105.00

  Given I partially complete an IR Renewal registration, but stop at the payment page
    And I have confirmed my email address
   When I start a new browser session
   When I start a new browser session
   When I log in to my account and edit my registration
   Then I confirm the declaration
   Then I should be shown the total cost "105.00"

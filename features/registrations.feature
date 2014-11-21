Feature: Registrations

As a Waste Carrier 
I want to register 
So that I am compliant with regulations

#@selenium
Scenario: Valid registration as an Individual
  Given I do not have an account yet
  And I have found out that I need to register in the lower tier
  Then I should see "Registering as a lower tier waste carrier/broker/dealer"
  #And I select business or organisation type "Sole trader"
  And I fill in "Business, organisation or trading name" with "Joe Bloggs"
  And I click "Next"
  And I fill in valid contact details
  And I click "Next"
  And I select the declaration checkbox
  And I click "Next"
  And I provide valid user details for sign up
  And I click "Next"
  Then I should see the Confirm Account page

#@javascript
Scenario: Valid registration as an Individual (version 2)
  Given I do not have an account yet
  And I have found out that I need to register in the lower tier
  And I provide valid individual trading name details
  And I provide valid contact details
  And I confirm the declaration
  And I provide valid user details for sign up
  And I click "Next"
  Then I should see the Confirm Account page
  And it should send me an Account Activation email
  And when I click on the activation link
  #Then my registration should be activated
  Then I should see the Registration Confirmed page
  And I can view the certificate
  And I can finish and return to govuk

#@javascript
Scenario: Valid registration for existing user (account email) - sign in during registration
  Given I have an activated account
  And I am on the initial page
  And I am not logged in
  And I have found out that I need to register in the lower tier
  And I provide valid individual trading name details
  And I provide valid contact details for "joe@example.com"
  And I confirm the declaration
  And I provide valid user details for sign in
  And I click "Next"
  Then I should see the Confirmation page
  And it should send a Registration Confirmation email to "joe@example.com"

Scenario: Valid registration for existing user - already logged in, no need to provide login details again
  Given I have an activated account
  And I am on the initial page
  And I am already logged in
  When I click on "New Registration"
  And I provide valid individual trading name details including business type
  And I provide valid contact details
  And I confirm the declaration
  And I click "Next"
  Then I should see the Confirmation page
  And it should send a Registration Confirmation email to "joe@example.com"

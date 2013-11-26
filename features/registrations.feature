Feature: Registrations

As a Waste Carrier 
I want to register 
So that I am compliant with regulations

#@selenium
Scenario: Valid registration as an Individual
  Given I do not have an account yet
  And I have found out that I need to register in the lower tier
  Then I should see "Waste Carrier Registration"
  And I should see "For a lower tier waste carrier/broker/dealer"
  And I select business or organisation type "Sole trader"
  And I fill in "Business, organisation or trading name" with "Joe Bloggs"
  And I click "Next"
  And I fill in valid contact details
  And I click "Next"
  And I select the declaration checkbox
  And I click "Next"
  And I provide valid user details for sign up
  And I click "Complete registration"
  Then I should see the Confirmation page

#@javascript
Scenario: Valid registration as an Individual (version 2)
  Given I do not have an account yet
  And I have found out that I need to register in the lower tier
  And I provide valid individual trading name details
  And I provide valid contact details
  And I confirm the declaration
  And I provide valid user details for sign up
  And I click "Complete registration"
  Then I should see the Confirmation page
  And it should send me a Registration Confirmation email

#@javascript
Scenario: Valid registration for existing user (account email) - sign in during registration
  Given I have an account
  And I am on the initial page
  And I am not logged in
  And I have found out that I need to register in the lower tier
  And I provide valid individual trading name details
  And I provide valid contact details for "joe@company.com"
  And I confirm the declaration
  And I provide valid user details for sign in
  And I click "Complete registration"
  Then I should see the Confirmation page

Scenario: Valid registration for existing user - already logged in, no need to provide login details again
  Given I have an account
  And I am on the initial page
  And I am already logged in
  When I click on "New Registration"
  And I provide valid individual trading name details
  And I provide valid contact details
  And I confirm the declaration
  And I click "Complete registration"
  Then I should see the Confirmation page


Feature: upper tier external edit
As a waste carrier
I want to be able to edit my registration
So that I can update my details with the Envrionment agency to continue to be registered as a waste carrier

# This background task creates a registration for which the scenarios can perform edit related tests
Background:
Given I have been funneled into the upper tier path
    And I am a carrier dealer
    And I provide the following company name: EditTest
    And I autocomplete my business address
    And I provide my personal contact details
    And I enter the details of the business owner
    And no key people in the organisation have convictions
    And I check the declaration
    And I provide my email address and create a password
    And I pay by card
  Then registration should be complete
    And I remember the registration id
  When I confirm account creation via email
    And I am shown the sign in page
    And I attempt to sign in
  Then I am successfully registered as an upper tier waste carrier

Scenario: Upper tier Edit with no change
    Given The edit link is available
    Then I click the edit link for: EditTest
      And I check the declaration
    Then I check that no changes have occurred

Scenario: Upper tier Edit with change, Online payment
    Given The edit link is available
    Then I click the edit link for: EditTest
      And I change the way we carry waste
      And I check the declaration
    Then I am asked to pay for the changes
      And I pay by card
    Then my edit should be complete

Scenario: Upper tier Edit with change, Offline payment
    Given The edit link is available
    Then I click the edit link for: EditTest
      And I change the way we carry waste
      And I check the declaration
    Then I am asked to pay for the changes
      And I choose pay via electronic transfer
    Then my edit should be awaiting payment


Feature: ir renewals assisted digital
As a agency user
I want to be able to renew ir registrations on behalf of external users
So that they can continue to be registered as a waste carriers

Background:
Given I am logged in as an NCCC agency user
    And I am renewing an IR registration
    And I have completed smart answers given my existing IR data
    And my waste carrier status is prepopulated
    And my company name is prepopulated

@happy_days
Scenario: Assisted Digital IR Renewal, No convictions, Online payment
    Given I autocomplete my business address
      And the caller provides his contact details
      And I enter the details of the business owner
      And no key people in the organisation have convictions
      And the caller declares the information provided is correct
      And I pay by card
    Then the callers registration should be complete
#    Then show me the page            # Useful for debugging to show current test page

Scenario: Assisted Digital IR Renewal, Convictions, Online payment
    Given I autocomplete my business address
      And the caller provides his contact details
      And I enter the details of the business owner
      And I declare convictions
      And I enter convictee details
      And the caller declares the information provided is correct
      And I pay by card
    Then the callers registration should be pending convictions checks


Scenario: Assisted Digital IR Renewal, No Convictions, Offline payment
    Given I autocomplete my business address
      And the caller provides his contact details
      And I enter the details of the business owner
      And no key people in the organisation have convictions
      And the caller declares the information provided is correct
      And I choose to pay by bank transfer
      And I make a note of the details
    Then the callers registration should be pending payment


Scenario: Assisted Digital IR Renewal, Convictions, Offline payment
    Given I autocomplete my business address
      And the caller provides his contact details
      And I enter the details of the business owner
      And I declare convictions
      And I enter convictee details
      And the caller declares the information provided is correct
      And I choose to pay by bank transfer
      And I make a note of the details
    Then the callers registration should be pending convictions checks

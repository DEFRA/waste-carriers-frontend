Feature: ir renewals
As a waste carrier
I want to be able to renew my ir registration
So that I can continue to be registered as a waste carrier

Background:
Given I am renewing an IR registration
    And I have completed smart answers given my existing IR data
    And my waste carrier status is prepopulated
    And my company name is prepopulated

@happy_days
Scenario: IR Renewal, No convictions, Online payment
    Given I autocomplete my business address
      And I provide my personal contact details
      And I enter the details of the business owner
      And no key people in the organisation have convictions
      And I check the declaration
      And I provide my email address and create a password
      And I pay by card
     When I confirm account creation via email
     Then I am shown the sign in page
       And I attempt to sign in
     Then I am registered as an upper tier waste carrier



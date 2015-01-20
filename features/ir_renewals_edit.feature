Feature: ir renewals with edits

  As a waste carrier
  I want to be able to renew my ir registration
  And change my business type
  So that I can continue to be registered as a waste carrier

Background:
  Given I am renewing an IR registration
  And I have completed smart answers, but changed my business type
  And my waste carrier status is prepopulated
  And my company name is prepopulated
  And I autocomplete my business address
  And I provide my personal contact details
  And I enter the details of the business owner

@javascript @quarantine
Scenario: IR Renewal changed business type causing full fee, No convictions, Online payment
  Given no key people in the organisation have convictions
  And I check the declaration
  And I provide my email address and create a password
  And I pay by card ensuring the total amount is 154.00
  And I am registered as an upper tier waste carrier
  Then registration should be complete
  When I re-request activation for my account
  Then I am shown the sign in page
  And I attempt to sign in
  Then I am successfully registered and activated as an upper tier waste carrier

Scenario: IR Renewal changed business type causing full fee, No Convictions, Offline payment
  Given no key people in the organisation have convictions
  And I check the declaration
  And I provide my email address and create a password
  And I choose pay via electronic transfer ensuring the total amount is 154.00
  And I make a note of the details
  And I am registered as an upper tier waste carrier pending payment
  Then registration should be pending payment
  When I activate my account by clicking the link in the activation email
  Then I am shown the sign in page
  And I attempt to sign in
  Then I am registered and activated as an upper tier waste carrier pending payment

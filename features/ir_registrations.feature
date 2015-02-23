Feature: IR registrations

  As a waste carrier
  I want to be able to renew my ir registration
  So that I can continue to be registered as a waste carrier

Background:
  Given I am renewing an IR registration
  And I have completed smart answers given my existing IR data
  And my waste carrier status is prepopulated
  And my company name is prepopulated

@javascript @happydays
Scenario: IR registrations, No convictions, Online payment
  Given I autocomplete my business address
  And I provide my personal contact details
  And I enter the details of the business owner
  And no key people in the organisation have convictions
  And I check the declaration
  And I provide my email address and create a password
  And I pay by card
  And I am registered as an upper tier waste carrier
  Then registration should be complete
  When I activate my account by clicking the link in the activation email
  And I attempt to sign in
  Then I am successfully registered and activated as an upper tier waste carrier

@javascript
Scenario: IR registrations, Convictions, Online payment
  Given I autocomplete my business address
  And I provide my personal contact details
  And I enter the details of the business owner
  And I declare convictions
  And I enter convictee details
  And I check the declaration
  And I provide my email address and create a password
  And I pay by card
  And I am registered as an upper tier waste carrier pending conviction checks
  Then registration should be pending convictions checks
  When I activate my account by clicking the link in the activation email
  And I attempt to sign in
  Then I am registered and activated as an upper tier waste carrier pending conviction checks

Scenario: IR registrations, No Convictions, Offline payment
  Given I autocomplete my business address
  And I provide my personal contact details
  And I enter the details of the business owner
  And no key people in the organisation have convictions
  And I check the declaration
  And I provide my email address and create a password
  And I choose to pay by bank transfer
  And I make a note of the details
  And I am registered as an upper tier waste carrier pending payment
  Then registration should be pending payment
  When I activate my account by clicking the link in the activation email
  And I attempt to sign in
  Then I am registered and activated as an upper tier waste carrier pending payment

Scenario: IR registrations, Convictions, Offline payment
  Given I autocomplete my business address
  And I provide my personal contact details
  And I enter the details of the business owner
  And I declare convictions
  And I enter convictee details
  And I check the declaration
  And I provide my email address and create a password
  And I choose to pay by bank transfer
  And I make a note of the details
  And I am registered as an upper tier waste carrier pending payment
  Then registration should be pending payment
  When I activate my account by clicking the link in the activation email
  And I attempt to sign in
  Then I am registered and activated as an upper tier waste carrier pending conviction checks
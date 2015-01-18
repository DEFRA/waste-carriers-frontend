@quarantine
Feature: upper tier external edit
  As a waste carrier
  I want to be able to edit my registration
  So that I can update my details with the Envrionment agency to continue to be registered as a waste carrier

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
  And I am registered as an upper tier waste carrier
  Then registration should be complete
  And I remember the registration id
  When I re-request activation for my account
  And I am shown the sign in page
  And I attempt to sign in
  Then I am successfully registered and activated as an upper tier waste carrier

@javascript @quarantine
Scenario: Upper tier Edit with no change
  Given The edit link is available
  Then I click the edit link for: EditTest
  And I check the declaration
  Then I check that no changes have occurred

@javascript @quarantine
Scenario: Upper tier Edit with change, Online payment
  Given The edit link is available
  Then I click the edit link for: EditTest
  And I change the way we carry waste
  And I check the declaration
  Then I am asked to pay for the edits
  And I pay by card
  Then my edit should be complete

@javascript @quarantine
Scenario: Upper tier Edit with change, Offline payment
  Given The edit link is available
  Then I click the edit link for: EditTest
  And I change the way we carry waste
  And I check the declaration
  Then I am asked to pay for the edits
  And I choose pay via electronic transfer
  Then my edit should be awaiting payment

@javascript @quarantine
Scenario: Upper tier Edit that forces a New Registration, Online payment
  Given The edit link is available
  Then I click the edit link for: EditTest
  And I change the legal entity
  And I check the declaration
  Then I am asked to pay for the edits expecting a full fee
  And I pay by card
  Then my edit with full fee should be complete

@javascript @quarantine
Scenario: Upper tier Edit that forces a New Registration, Offline payment
  Given The edit link is available
  Then I click the edit link for: EditTest
  And I change the legal entity
  And I check the declaration
  Then I am asked to pay for the edits expecting a full fee
  And I choose pay via electronic transfer
  Then my edit with full fee should be awaiting payment
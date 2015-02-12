Feature: upper tier external edit
  As a waste carrier
  I want to be able to edit my registration
  So that I can update my details with the Envrionment agency to continue to be registered as a waste carrier

Background:
  Given a "ST_UT_online_complete" upper tier registration paid for by "Bank Transfer" with 0 copy cards
  And I log in to the "st_ut@example.org" account

Scenario: Upper tier Edit with no change
  Given The edit link is available
  Then I click the Edit Registration link
  And I check the declaration
  Then I check that no changes have occurred

@javascript
Scenario: Upper tier Edit with change, Online payment
  Given The edit link is available
  Then I click the Edit Registration link
  And I change the way we carry waste
  And I check the declaration
  Then I am asked to pay for the edits
  And I pay by card
  Then my edit should be complete

Scenario: Upper tier Edit with change, Offline payment
  Given The edit link is available
  Then I click the Edit Registration link
  And I change the way we carry waste
  And I check the declaration
  Then I am asked to pay for the edits
  And I choose pay via electronic transfer
  Then my edit should be awaiting payment

@javascript
Scenario: Upper tier Edit that forces a New Registration, Online payment
  Given The edit link is available
  Then I click the Edit Registration link
  And I change the legal entity
  And I check the declaration
  Then I am asked to pay for the edits expecting a full fee
  And I pay by card
  Then my edit with full fee should be complete

Scenario: Upper tier Edit that forces a New Registration, Offline payment
  Given The edit link is available
  Then I click the Edit Registration link
  And I change the legal entity
  And I check the declaration
  Then I am asked to pay for the edits expecting a full fee
  And I choose pay via electronic transfer
  Then my edit with full fee should be awaiting payment

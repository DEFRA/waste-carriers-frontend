Feature: Edit registration
  As a registered waste carrier
  I want to be able to edit my registration
  So that my details are updated

Background:
  Given a "PB_UT_online_complete" upper tier registration paid for by "World Pay" with 0 copy cards

Scenario: Public Body Waste carrier can edit their registration and pay by bank transfer
  Given I log in as a Public body waste carrier
  Then I visit the edit registration page
  And I edit the registered address
  And I change the way we carry waste
  Then I expect to see a charge of £40
  And I check the declaration
  Then I choose to pay by bank transfer
  Then I click continue
  And I expect to see a charge of £40
  Then I visit the edit registration page
  And I see the edited registered address name

@javascript
Scenario: Public Body Waste carrier can edit their registration and pay by worldpay
  Given I log in as a Public body waste carrier
  Then I visit the edit registration page
  And I edit the registered address
  And I change the way we carry waste
  Then I expect to see a charge of £40
  And I check the declaration
  Then I pay by card
  And I expect to see a charge of £40
  Then I visit the edit registration page
  And I see the edited registered address name

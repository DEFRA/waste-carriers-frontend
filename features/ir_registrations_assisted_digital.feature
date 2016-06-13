
Feature: ir registrations assisted digital

  As a agency user
  I want to be able to renew ir registrations from the old IR system, on behalf of external users
  So that they can continue to be registered as a waste carriers

Background: Environment agency user is logged into system
Given I have signed in as an Environment Agency user
And have chosen to renew a customers existing licence

@javascript @happy_days
Scenario: Assisted Digital IR registrations, No convictions, Online payment
  Given I am registering an IR registration for a Sole trader and pay by credit card
  When I make no other changes to my registration details
  Then a renewal fee will be charged
  And the callers registration should be complete when payment is successful

#Change Company Address
@javascript
Scenario: IR registrations - AD - Limited company changes business details should be charged renewal fee
  Given I am renewing a valid CBD IR registration for limited company
  When I only change business details
  Then I should be shown the total cost is the charge amount and renewal amount "105.00"
  And the callers registration should be pending convictions checks when payment is successful

#Change Company Number
@javascript
Scenario: IR registrations - AD - Limited company changes business details should be charged renewal fee
  Given I am renewing a valid CBD IR registration for limited company
  When I Change the Company Number
  Then I should be shown the total cost is the charge amount and renewal amount "154.00"
  And the callers registration should be pending convictions checks when payment is successful

#Change Business Name
@javascript
Scenario: IR registrations - AD - Limited company changes business name should be charged renewal fee
  Given I am renewing a valid CBD IR registration for limited company
  When I only change business name
  Then I should be shown the total cost is the charge amount and renewal amount "105.00"
  And the callers registration should be complete when payment is successful

@javascript
Scenario: Assisted Digital IR registrations, Convictions, Online payment
   Given I am registering an IR registration for a Public body and pay by credit card
   When I make no other changes to my registration details
   Then a renewal fee will be charged
   And the callers registration should be pending convictions checks when payment is successful

Scenario: Assisted Digital IR registrations, No Convictions, Offline payment
  Given I am registering an IR registration for a Partnership and pay by bank transfer
  When I make no other changes to my registration details
   Then a renewal fee will be charged
   And the callers registration should be pending payment
   And the correct renewal charge should be shown

@javascript
Scenario: Assisted Digital IR registrations, Convictions, Offline payment
  Given I am registering an IR registration for a limited company with convictions and pay by bank transfer
  When I make no other changes to my registration details
  Then a renewal fee will be charged
  And the callers registration should be pending convictions checks when payment is successful

#Change Carrier Type Carrier Dealer
@javascript @happy_days
Scenario: IR registrations - AD - Limited company changes waste carrier type and pays by credit card
  Given I am registering an IR registration for a limited company changing waste carrier type and pay by credit card
  When I make no other changes to my registration details
  Then there will be a renewal and edit amount charged
  And the callers registration should be complete when payment is successful
  And I should see the Finish page

@happy_days
Scenario: IR registrations - AD - Sole Trader changes waste carrier type with convictions and pays by bank transfer
  Given I am registering an IR registration for a Sole trader changing waste carrier type with convictions and pay by bank transfer
  When I make no other changes to my registration details
  Then there will be a renewal and edit amount charged
  And the callers registration should be pending payment
  And the correct renewal and edit charge should be shown

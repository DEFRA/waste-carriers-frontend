@wip
Feature: ir registrations assisted digital

  As a agency user
  I want to be able to renew ir registrations on behalf of external users
  So that they can continue to be registered as a waste carriers

Background: Environment agency user is logged into system
Given I have signed in as an Environment Agency user
And have chosen to renew a customers existing licence

#Actually charges a new registration fee
@wip
Scenario: IR registrations - AD - Limited company changes business details should be charged renewal fee
  Given I am renewing a valid CBD IR registration for limited company
  When I only change business details
  Then I should be shown the total cost is the charge amount and renewal amount "105.00"
  And have the option to pay by Credit or Debit card or by bank transfer

#Actually charges a new registration fee
@wip
Scenario: IR registrations - AD - Limited company changes business name should be charged renewal fee
  Given I am renewing a valid CBD IR registration for limited company
  When I only change business name
  Then I should be shown the total cost is the charge amount and renewal amount "105.00"
  And have the option to pay by Credit or Debit card or by bank transfer

@javascript @happy_days
Scenario: Assisted Digital IR registrations, No convictions, Online payment
  Given I am renewing an IR registration for a Sole trader and pay by credit card
  # Then I should be shown the total cost is the charge amount and renewal amount "154.00"
  And the callers registration should be complete

@javascript @wip
Scenario: Assisted Digital IR registrations, Convictions, Online payment
  Given I autocomplete my business address
  And the caller provides his contact details
  And I enter the details of the business owner
  And I declare convictions
  And I enter convictee details
  And the caller declares the information provided is correct
  And I pay by card
  Then the callers registration should be pending convictions checks

@wip
Scenario: Assisted Digital IR registrations, No Convictions, Offline payment
  Given I autocomplete my business address
  And the caller provides his contact details
  And I enter the details of the business owner
  And no key people in the organisation have convictions
  And the caller declares the information provided is correct
  And I choose to pay by bank transfer
  And I make a note of the details
  Then the callers registration should be pending payment
@wip
Scenario: Assisted Digital IR registrations, Convictions, Offline payment
  Given I autocomplete my business address
  And the caller provides his contact details
  And I enter the details of the business owner
  And I declare convictions
  And I enter convictee details
  And the caller declares the information provided is correct
  And I choose to pay by bank transfer
  And I make a note of the details
  Then the callers registration should be pending convictions checks

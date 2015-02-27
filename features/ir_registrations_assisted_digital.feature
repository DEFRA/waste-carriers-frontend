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

#charges new registration fee
@javascript @happy_days
Scenario: Assisted Digital IR registrations, No convictions, Online payment
  Given I am registering an IR registration for a Sole trader and pay by credit card
  Then a renewal fee will be charged
  And the callers registration should be complete when payment is successful

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

  @wip
Scenario: IR registrations - AD - Limited company changes waste carrier type
Given I am renewing a valid CBD IR registration for limited company
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from CBD to CD
And I Enter business details
And I Enter their contact details
And I Enter key people details
And I have no relevant convictions
And I confirm their details
Then I should be shown the total cost is the charge amount and renewal amount "145.00"
And have the option to pay by Credit or Debit card or by bank transfer


@wip
Scenario: IR registrations - AD - Sole Trader changes waste carrier type
Given I am renewing a valid IR registration for sole trader
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from CD to CBD
And I Enter business details
And I Enter their contact details
And I Enter my details
And I have no relevant convictions
And I confirm their details
Then I should be shown the total cost is the charge amount and renewal amount "145.00"
And have the option to pay by Credit or Debit card or by bank transfer


@wip
Scenario: IR registrations - AD - Partner changes waste carrier type
Given I am renewing a valid CBD IR registration for Partnership
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from CBD to BD
And I Enter business details
And I Enter their contact details
And I Enter key people details
And I have no relevant convictions
And I confirm their details
Then I should be shown the total cost "145.00"
And have the option to pay by Credit or Debit card or by bank transfer

# Check Public body data
@wip
Scenario: IR registrations - AD - Public body changes waste carrier type
Given I am renewing a valid CD IR registration for Public Body
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from CD to BD
And I Enter business details
And I Enter their contact details
And I Enter key people details
And I have no relevant convictions
And I confirm their details
Then I should be shown the total cost "145.00"
And have the option to pay by Credit or Debit card or by bank transfer

@wip
Scenario: IR registrations - AD - Limited company changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid BD IR registration for limited company
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from BD to CD
And I Enter business details
And I Enter their contact details
And I Enter key people details
And I have no relevant convictions
And I confirm their details
Then I should be shown the total cost "145.00"
And have the option to pay by Credit or Debit card or by bank transfer

@wip
Scenario: IR registrations - AD - Partner changes waste carrier type
Given I am renewing a valid BD IR registration for Partnership
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from BD to CBD
And I Enter business details
And I Enter their contact details
And I Enter key people details
And I have no relevant convictions
And I confirm their details
Then I should be shown the total cost "145.00"
And have the option to pay by Credit or Debit card or by bank transfer

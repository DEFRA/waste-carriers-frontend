Feature: IR renewal - Assisted digital Waste carrier edits waste carrier type
As an Environment Agency User
I want to be able to change waste carrier types when I am renewing registrations from the old system (IR)
So that I can easy amend details before renewing registrations

The three types of Waste carrier are Carrier Dealer (CD), Broker Dealer (BD) or Carrier Broker Dealer (CBD)

Background: Environment agency user is logged into system
Given I have logged in as an Environment Agency user
And have chosen to renew a customers existing licence

@wip
Scenario: IR renewal - AD - Limited company changes waste carrier type
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
Scenario: IR renewal - AD - Sole Trader changes waste carrier type
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
Scenario: IR renewal - AD - Partner changes waste carrier type
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
Scenario: IR renewal - AD - Public body changes waste carrier type
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
Scenario: IR renewal - AD - Limited company changes waste carrier type
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
Scenario: IR renewal - AD - Partner changes waste carrier type
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


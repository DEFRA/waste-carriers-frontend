Feature: IR renewal - Assisted digital Waste carrier edits business or organisation name
As an Environment Agency User
I want to be able to a change business or organisation's name when I am renewing registrations from the old system (IR)
So that I can easy amend details before renewing registrations

The three types of Waste carrier are Carrier Dealer (CD), Broker Dealer (BD) or Carrier Broker Dealer (CBD)

Background: Environment agency user is logged into system
Given I have logged in as an Environment Agency user
And have chosen to renew a customers existing licence

@wip
Scenario: IR renewal - AD - Limited company changes changes name
Given I am renewing a valid CBD IR registration for limited company
And I don't change business type
And the smart answers keep me in Upper tier
And I don't change waste carrier type
When I change business details
And I Enter their contact details
And I Enter key people details
And I have no relevant convictions
And I confirm their details
Then I should be shown the total cost is the charge amount and renewal amount "105.00"
And have the option to pay by Credit or Debit card or by bank transfer


@wip
Scenario: IR renewal - AD - Sole Trader changes changes name
Given I am renewing a valid IR registration for sole trader
And I don't change business type
And the smart answers keep me in Upper tier
And I don't change waste carrier type
When I change business details
And I Enter their contact details
And I Enter my details
And I have no relevant convictions
And I confirm their details
Then I should be shown the total cost is the charge amount and renewal amount "105.00"
And have the option to pay by Credit or Debit card or by bank transfer


@wip
Scenario: IR renewal - AD - Partner changes name
Given I am renewing a valid CBD IR registration for Partnership
And I don't change business type
And the smart answers keep me in Upper tier
And I don't change waste carrier type
When I change business details
And I Enter their contact details
And I Enter key people details
And I have no relevant convictions
And I confirm their details
Then I should be shown the total cost is the charge amount and renewal amount "105.00"
And have the option to pay by Credit or Debit card or by bank transfer

# Check Public body data
@wip
Scenario: IR renewal - AD - Public body changes name
Given have chosen to renew an existing licence
And I don't change business type
And the smart answers keep me in Upper tier
And I don't change waste carrier type
When I change business details
And I Enter their contact details
And I Enter key people details
And I have no relevant convictions
And I confirm their details
Then I should be shown the total cost is the charge amount and renewal amount "105.00"
And have the option to pay by Credit or Debit card or by bank transfer




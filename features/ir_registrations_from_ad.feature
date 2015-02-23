Feature: IR registrations - Assisted digital
As an Environment Agency User
I want to be able to a change business or organisation's name when I am renewing registrations from the old system (IR)
So that I can easy amend details before renewing registrations

The three types of Waste carrier are Carrier Dealer (CD), Broker Dealer (BD) or Carrier Broker Dealer (CBD)

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

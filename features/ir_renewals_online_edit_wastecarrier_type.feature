Feature: IR renewal - Online Waste carrier edits waste carrier type
As a waste carrier 
I want to be able to change my waste carrier type when I renew my registration using my information from the old system (IR)
So that I can easy amend my details before renewing my registration

The three types of Waste carrier are Carrier Dealer (CD), Broker Dealer (BD) or Carrier Broker Dealer (CBD)


@wip
Scenario: IR renewal - Limited company changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid CBD IR registration for limited company
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from CBD to CD
And I Enter business details
And I Enter my contact details
And I Enter key people details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "145.00"
And have the option to pay by Credit or Debit card or by bank transfer


@wip
Scenario: IR renewal - Sole Trader changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid IR registration for sole trader
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from CD to CBD
And I Enter business details
And I Enter my contact details
And I Enter my details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "145.00"
And have the option to pay by Credit or Debit card or by bank transfer

@wip
Scenario: IR renewal - Partner changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid CBD IR registration for Partnership
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from CBD to BD
And I Enter business details
And I Enter my contact details
And I Enter key people details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "145.00"
And have the option to pay by Credit or Debit card or by bank transfer

# Doesn't seem to be picking up Public body data
@wip
Scenario: IR renewal - Public body changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid CD IR registration for Public Body
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from CD to BD
And I Enter business details
And I Enter my contact details
And I Enter key people details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "145.00"
And have the option to pay by Credit or Debit card or by bank transfer

@wip
Scenario: IR renewal - Limited company changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid BD IR registration for limited company
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from BD to CD
And I Enter business details
And I Enter my contact details
And I Enter key people details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "145.00"
And have the option to pay by Credit or Debit card or by bank transfer

@wip
Scenario: IR renewal - Partner changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid BD IR registration for Partnership
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from BD to CBD
And I Enter business details
And I Enter my contact details
And I Enter key people details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "145.00"
And have the option to pay by Credit or Debit card or by bank transfer

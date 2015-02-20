Feature: IR registrations - Online Waste carrier changes business name
As a waste carrier
I want to be able to change my business name when I renew my registration using my information from the old system (IR)
So that I can easy amend my details before renewing my registration

The three types of Waste carrier are Carrier Dealer (CD), Broker Dealer (BD) or Carrier Broker Dealer (CBD)

# Fails on build server because searching for IR No. always returns no results
@wip
Scenario: IR registrations - Limited company changes name
Given have chosen to renew an existing licence
And I am renewing a valid CBD IR registration for limited company
And I don't change business type
And the smart answers keep me in Upper tier
And I don't change waste carrier type
When I change business details
And I Enter my contact details
And I Enter key people details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "105.00"
And have the option to pay by Credit or Debit card or by bank transfer

# Fails on build server because searching for IR No. always returns no results
@wip
Scenario: IR registrations - Sole Trader changes name
Given have chosen to renew an existing licence
And I am renewing a valid IR registration for sole trader
And I don't change business type
And the smart answers keep me in Upper tier
And I don't change business type
When I change business details
And I Enter my contact details
And I Enter my details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "105.00"
And have the option to pay by Credit or Debit card or by bank transfer

# Fails on build server because searching for IR No. always returns no results
@wip
Scenario: IR registrations - Partner changes name
Given have chosen to renew an existing licence
And I am renewing a valid CBD IR registration for Partnership
And I don't change business type
And the smart answers keep me in Upper tier
And I don't change business type
When I change business details
And I Enter my contact details
And I Enter key people details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "105.00"
And have the option to pay by Credit or Debit card or by bank transfer

# Doesn't seem to be picking up Public body data
@wip
Scenario: IR registrations - Public body changes name
Given have chosen to renew an existing licence
And I am renewing a valid CD IR registration for Public Body
And I don't change business type
And the smart answers keep me in Upper tier
And I don't change business type
When I change business details
And I Enter my contact details
And I Enter key people details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "105.00"
And have the option to pay by Credit or Debit card or by bank transfer

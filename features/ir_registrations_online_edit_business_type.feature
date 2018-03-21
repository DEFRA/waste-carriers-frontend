Feature: IR registrations - Online Waste carrier changes business type
As a waste carrier
I want to be able to change my business type when I renew my registration using my information from the old system (IR)
So that I can easy amend my details before renewing my registration

The three types of Waste carrier are Carrier Dealer (CD), Broker Dealer (BD) or Carrier Broker Dealer (CBD)

Background: Waste carrier choose to renew registration from IR
Given have chosen to renew an existing licence
@javascript
Scenario: IR registrations - Limited company changes business type and is prompted to complete new registration
Given PENDING: I am renewing a valid CBD IR registration for limited company
And I change business type to Sole Trader
And the smart answers keep me in Upper tier
And I don't change waste carrier type
And I change business details
And I Enter my contact details
And I confirm my postal address
And I Enter my details
And I have no relevant convictions
When I confirm my details
Then I should be shown the total cost "154.00"
And registration should be complete when payment is successful


@javascript
Scenario: IR registrations - Sole Trader changes business type and is prompted to complete new registration
Given PENDING: I am renewing a valid IR registration for sole trader
And I change business type to ltd company
And the smart answers keep me in Upper tier
And I don't change business type
And I enter an active company number
And I enter my company name and address
And I change business details
And I Enter my contact details
And I confirm my postal address
And I Enter my details
And I have no relevant convictions
When I confirm my details
Then I should be shown the total cost "154.00"
And registration should be complete when payment is successful

@javascript
Scenario: IR registrations - Partner changes business type and is prompted to complete new registration
Given PENDING: I am renewing a valid CBD IR registration for Partnership
And I change business type to ltd company
And the smart answers keep me in Upper tier
And I don't change business type
And I enter an active company number
And I enter my company name and address
And I change business details
And I Enter my contact details
And I confirm my postal address
And I Enter key people details
And I have no relevant convictions
When I confirm my details
Then I should be shown the total cost "154.00"
And registration should be complete when payment is successful

@javascript
Scenario: IR registrations - Public body changes business type and is prompted to complete new registration
Given PENDING: I am renewing a valid CD IR registration for Public Body
And I change business type to ltd company
And the smart answers keep me in Upper tier
And I don't change business type
And I enter an active company number
And I enter my company name and address
And I change business details
And I Enter my contact details
And I confirm my postal address
And I Enter key people details
And I have no relevant convictions
When I confirm my details
Then I should be shown the total cost "154.00"
And registration should be complete when payment is successful

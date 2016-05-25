Feature: IR registrations - Online Waste carrier edits waste carrier type
As a waste carrier
I want to be able to change my waste carrier type when I renew my registration using my information from the old system (IR)
So that I can easy amend my details before renewing my registration

The three types of Waste carrier are Carrier Dealer (CD), Broker Dealer (BD) or Carrier Broker Dealer (CBD)


@javascript
Scenario: IR registrations - Limited company changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid CBD IR registration for limited company
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from CBD to CD
And I Enter business details
And I Enter my contact details
And I confirm my postal address
And I Enter key people details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "145.00"
And registration should be complete when payment is successful


@javascript
Scenario: IR registrations - Sole Trader changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid IR registration for sole trader
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from CD to CBD
And I Enter business details
And I Enter my contact details
And I confirm my postal address
And I Enter key people details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "145.00"
And registration should be complete when payment is successful

@javascript @AndyTest
Scenario: IR registrations - Partner changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid CBD IR registration for Partnership
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from CBD to BD
And I Enter business details
And I Enter my contact details
And I confirm my postal address
And I enter multiple key people
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "145.00"
And registration should be complete when payment is successful

@javascript
Scenario: IR registrations - Public body changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid CD IR registration for Public Body
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from CD to BD
And I Enter business details
And I Enter my contact details
And I confirm my postal address
And I Enter key people details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "145.00"
And registration should be complete when payment is successful

@javascript
Scenario: IR registrations - Limited company changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid BD IR registration for limited company
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from BD to CD
And I Enter business details
And I Enter my contact details
And I confirm my postal address
And I Enter key people details
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "105.00"
And registration should be complete when payment is successful

@javascript
Scenario: IR registrations - Partner changes waste carrier type
Given have chosen to renew an existing licence
And I am renewing a valid BD IR registration for Partnership
And I don't change business type
And the smart answers keep me in Upper tier
When I change waste carrier type from BD to CBD
And I Enter business details
And I Enter my contact details
And I confirm my postal address
And I enter multiple key people
And I have no relevant convictions
And I confirm my details
Then I should be shown the total cost "145.00"
And registration should be complete when payment is successful

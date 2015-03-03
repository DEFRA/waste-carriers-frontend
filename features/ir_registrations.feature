Feature: IR registrations

  As a waste carrier
  I want to be able to renew my registration from IR
  So that I can continue to be registered as a waste carrier

Background:
  Given I have chosen to renew my registration from IR

#Should be offered the chance to order copy cards, commented step should be included when bug fixed
#https://www.pivotaltracker.com/story/show/86997468
@javascript @happydays
Scenario: IR registrations, No convictions, Online payment
  When I enter my IR registration number for a Sole trader and pay by credit card
  And I make no other changes to my registration details
  Then I will be charged a renewal fee
  And registration should be complete when payment is successful
  

@javascript
Scenario: IR registrations, Convictions, Online payment
  When I enter my IR registration number for a limited company and pay by credit card
  And I make no other changes to my registration details
  Then I will be charged a renewal fee
  And my registration should be pending convictions checks when payment is successful

@wip
Scenario: IR registrations, No Convictions, Offline payment
  Given I autocomplete my business address
  And I provide my personal contact details
  And I enter the details of the business owner
  And no key people in the organisation have convictions
  And I check the declaration
  And I provide my email address and create a password
  And I choose to pay by bank transfer
  And I make a note of the details
  And I am registered as an upper tier waste carrier pending payment
  Then registration should be pending payment
  When I activate my account by clicking the link in the activation email
  And I attempt to sign in
  Then I am registered and activated as an upper tier waste carrier pending payment
@wip
Scenario: IR registrations, Convictions, Offline payment
  Given I autocomplete my business address
  And I provide my personal contact details
  And I enter the details of the business owner
  And I declare convictions
  And I enter convictee details
  And I check the declaration
  And I provide my email address and create a password
  And I choose to pay by bank transfer
  And I make a note of the details
  And I am registered as an upper tier waste carrier pending payment
  Then registration should be pending payment
  When I activate my account by clicking the link in the activation email
  And I attempt to sign in
  Then I am registered and activated as an upper tier waste carrier pending conviction checks

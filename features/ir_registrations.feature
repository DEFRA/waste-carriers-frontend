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
  When I enter my IR registration number for a limited company with convictions and pay by credit card
  And I make no other changes to my registration details
  Then I will be charged a renewal fee
  And my registration should be pending convictions checks when payment is successful


Scenario: IR registrations, No Convictions, Offline payment
  When I enter my IR registration number for a partnership and pay by credit card
  And I make no other changes to my registration details
  Then I will be charged a renewal fee
  And my registration should be pending payment
  And my correct renewal charge should be shown


Scenario: IR registrations, Convictions, Offline payment
  When I enter my IR registration number for a Sole trader with convictions and pay by bank transfer
  And I make no other changes to my registration details
  Then I will be charged a renewal fee
  And my registration should be pending payment


Feature: Copy cards

  As a registered waste carrier
  I want to be able to order additional copy cards
  So that I can show my registration details to customers

Background:
  Given a "PB_UT_online_complete" upper tier registration paid for by "World Pay" with 3 copy cards
  

@javascript
Scenario: Public Body Waste carrier can order copy cards and pay by credit card online
  Given I log in as a Public body waste carrier
  When I order and pay for 3 cards with Mastercard
  Then I will be shown confirmation of paid order


Scenario Outline: Public Body Waste carrier can order copy cards and pay via bank transfer online
  Given I log in as a Public body waste carrier
  And I choose to order copy cards for my registration
  When I order "registration_copy_cards" with "<card_number>" and choose to pay offline
  Then the total amount is <total_charge>
    Examples:
    | card_number	|	total_charge |
    |	1			      |	5.00		     |
    |	5			      |	25.00		     |
    |	10		      |	50.00		     |

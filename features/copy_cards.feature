
Feature: Copy cards

  As a registered waste carrier
  I want to be able to order additional copy cards
  So that I can show my registration details to customers

Background:
  Given a "PB_UT_online_complete" upper tier registration paid for by "World Pay" with 3 copy cards
  

@javascript @quarantine
Scenario: Public Body Waste carrier can order copy cards and pay by credit card online
  Given I log in as a Public body
  And I have selected copy cards option for that registration
  And I have chosen 3 copy cards
  And I choose to pay by credit card
  And I choose to pay by Mastercard
  And I can confirm the amount charged is correct
  When I submit my Mastercard detals
  Then I will be shown confirmation of paid order

Scenario Outline: Public Body Waste carrier can order copy cards and pay via bank transfer online
  Given I log in as a Public body
  And I have selected copy cards option for that registration
  And I'm on the copy cards payment summary page
  And I will be prompted to fill in "registration_copy_cards" with "<card_number>"
  And I choose pay via electronic transfer ensuring the total amount is <total_charge>
    Examples:
    | card_number	|	total_charge |
    |	1			      |	5.00		     |
    |	5			      |	25.00		     |
    |	10		      |	50.00		     |

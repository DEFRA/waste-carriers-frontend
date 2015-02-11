Feature: Copy cards

  As a registered waste carrier
  I want to be able to order additional copy cards
  So that I can show my registration details to customers

# This background task creates a registration for which the scenarios can perform renew related tests
Background:
  Given a "ST_UT_online_complete" upper tier registration paid for by "Bank Transfer" with 0 copy cards
  And I log in to the "st_ut@example.org" account

Scenario: Waste carrier can order copy cards - external
  When I visit the Add Copy Cards page for my registration
  Then I will be prompted to fill in "registration_copy_cards" with "3"
   And I can choose to pay by card or electronic transfer

@javascript
Scenario Outline: Pay for copy cards via Worldpad - external
  When I visit the Add Copy Cards page for my registration
  And I'm on the copy cards payment summary page
  And I will be prompted to fill in "registration_copy_cards" with "<card_number>"
  And I pay by card ensuring the total amount is <total_charge>
  Then I will be shown confirmation of paid order
    Examples:
      | card_number | total_charge |
      | 1           | 5.00         |
      | 5           | 25.00        |

Scenario Outline: Pay for copy cards via bank transfer - external
  When I visit the Add Copy Cards page for my registration
   And I'm on the copy cards payment summary page
   And I will be prompted to fill in "registration_copy_cards" with "<card_number>"
   And I choose pay via electronic transfer ensuring the total amount is <total_charge>
   And I make a note of the details
  Then I will be shown confirmation of unpaid order
   Examples:
   | card_number | total_charge |
   |   1         |  5.00        |
   |   5         | 25.00        |
   |  10         | 50.00        |

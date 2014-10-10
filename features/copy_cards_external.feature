Feature: Copy cards
  As a registered waste carrier
  I want to be able to order additional copy cards
  So that I can show my registration details to customers
  
# This background task creates a registration for which the scenarios can perform renew related tests
Background:
Given I have been funneled into the upper tier path
    And I am a carrier dealer
    And I provide the following company name: CopyCardTest
    And I autocomplete my business address
    And I provide my personal contact details
    And I enter the details of the business owner
    And no key people in the organisation have convictions
    And I check the declaration
    And I provide my email address and create a password
    And I pay by card
  Then registration should be complete
    And I remember the registration id
    And I finish my registration
  When I re-request activation for my account
    And I am shown the sign in page
    And I attempt to sign in
  Then I am successfully registered as an upper tier waste carrier

Scenario: Waste carrier can order copy cards - external
  Given I have selected copy cards option for that registration
  And I will be prompted to fill in "registration_copy_cards" with "3"
  And I can choose to pay by card or electronic transfer

Scenario Outline: Pay for copy cards via Worldpad - external
  Given I have selected copy cards option for that registration
  And I'm on the copy cards payment summary page
  And I will be prompted to fill in "registration_copy_cards" with "<card_number>"
  And I pay by card ensuring the total amount is <total_charge>
  Then I will be shown confirmation of paid order
#  # No confirmation payment is sent by the system at this time?
#  And confirmation payment email will be sent
#  # There is no external user charge history. Only the agency users have that ability is that what the test requires?
#  And Charge history will be updated with <total_charge>
#  And Payment history will be updated

Examples:
| card_number	|	total_charge	|
|	1			|		5.00		|
|	5			|		25.00		|
|	10			|		50.00		|

Scenario Outline: Pay for copy cards via bank transfer - external
  Given I have selected copy cards option for that registration
  And I'm on the copy cards payment summary page
  And I will be prompted to fill in "registration_copy_cards" with "<card_number>"
  And I choose pay via electronic transfer ensuring the total amount is <total_charge>
  And I make a note of the details
  Then I will be shown confirmation of unpaid order
#  # There is no external user charge history. Only the agency users have that ability is that what the test requires?
##  And Charge history will be updated with <total_charge>

Examples:
| card_number	|	total_charge	|
|	1			|		5.00		|
|	5			|		25.00		|
|	10			|		50.00		|


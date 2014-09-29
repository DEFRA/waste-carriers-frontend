Feature: Copy cards
  As a registered waste carrier
  I want to be able to order additional copy cards
  So that I can show my registration details to customers

Scenario: Waste carrier can order copy cards - external
  Given I am logged in as a waste carrier 
  And I'm on the on the Your Registrations page
  And I have an active registration
  When I have selected copy cards option for that registration
  Then I will be prompted for the number of copy cards to order
  And I can choose to pay by card or electronic transfer

Scenario Outline: Pay for copy cards via Worldpad - external
  Given I am logged in as a waste carrier
  And I have an active registration
  And I have selected copy cards option for that registration
  And I'm on the copy cards payment summary page
  And I choose <card_number>
  And Total charge will be <total_charge>
  And select to pay by debit/credit card
  And I enter my credit card details
  When I select to make payment
  Then payment will be successful
  And copy card confirmation page will be displayed
  And confirmation payment email will be sent
  And Charge history will be updated with <total_charge>
  And Payment history will be updated

Examples:
| card_number	|	total_charge	|
|	1			|		5			|
|	5			|		25			|
|	10			|		50			|

Scenario Outline: Pay for copy cards via bank transfer - external
  Given I am logged in as a waste carrier
  And I have an active registration
  And I have selected copy cards option for that registration
  And I'm on the copy cards payment summary page
  And I choose <card_number>
  And Total charge will be <total_charge>
  And select to pay by bank transfer
  And I will be shown pay by bank transfer details
  When I confirm order
  Then I will be shown confirmation of order
  And Charge history will be updated with <total_charge>

Examples:
| card_number	|	total_charge	|
|	1			|		5			|
|	5			|		25			|
|	10			|		50			|




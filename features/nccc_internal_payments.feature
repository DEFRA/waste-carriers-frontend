Feature: nccc internal payments

  As an NCCC user
  I want to be able to view waste carrier payment details
  So that I can view payment status and enter payment from non online payment methods

Background:
  Given I am logged in as an NCCC agency user
  And I create an upper tier registration on behalf of a caller who wants to pay offline
  And I make a note of the details
  And I remember the registration id
  And I finish the registration
  And I have found a registrations payment details by name: Assisted Enterprises & Co
  And I logout
  And I am logged in as a finance basic user
  And I have found a registrations payment details by name: Assisted Enterprises & Co

@happy_days
Scenario: Successful payment of total balance
  When I select to enter payment
  And I pay the full amount owed
  And I enter payment details
  And I confirm payment
  Then payment status will be paid
  And payment history will be updated
  And payment balance will be 0.00

Scenario Outline: Internal payment scenarios, underpayment and overpayment
  When I select to enter payment
  And payment status is <start_payment_status>
  And balance is <balance_amount>
  And I enter <payment_amount>
  And I enter payment details
  And I confirm payment
  Then payment status will be <end_payment_status>
  And payment history will be updated
  And payment balance will be <outcome_balance>
    # Changed these original values as they do not function as expected. Once the scenario runs for every entry in this list is gets
    # a new registraiton. Not simple updates to the existing one found. As such the starting page never has the status
    # other that the starting status. Thus this table should always have balance_amount of 154, and start_payment_status of pending
    Examples:
    | balance_amount | payment_amount |	start_payment_status | end_payment_status | outcome_balance |
    |	154				     | 154			      |	pending				       | paid 					    |	0.00				    |
    |	154				     | 54			        |	pending  	           | pending					  |	100.00			 	  |
    |	154				     | 153.99		      |	pending              | pending					  |	0.01				    |
    |	154				     | 154.01		      |	pending			         | overpaid     			|	0.01 				    |
    |	154				     | 200 		        |	pending			         | overpaid     			|	46.00 				  |

Feature: nccc internal payments
As an NCCC user 
I want to be able to view waste carrier payment details
So that I can view payment status and enter payment from non online payment methods


Background:
Given I am logged in as a finance basic user
  And I create an upper tier registration on behalf of a caller for payments
  And I have found a registrations payment details

@happy_days
Scenario: Successful payment of total balance
  When I select to enter payment
  And I pay the full amount owed
  And I enter payment details
  And I confirm payment
  Then payment status will be paid
  And payment history will be updated
  And payment balance will be 0.00
#  Then show me the page

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

# overpaid underpaid status to TBC
# check bounced cheques
Examples:
| balance_amount	| payment_amount|	start_payment_status	|	end_payment_status		|	outcome_balance		|
|	154				|	154			|		pending				|	paid 					|	0.00				|
# Changed these original values as they do not function as expected. Once the scenario runs for every entry in this list is gets
# a new registraiton. Not simple updates to the existing one found. As such the starting page never has the status 
# other that the starting status. Thus this table should always have balance_amount of 154, and start_payment_status of pending
|	154				|	54			|		pending  	        |	pending					|	100.00			 	|
|	154				|	153.99		|		pending             |	pending					|	0.01				|
|	154				|	154.01		|		pending			    |	overpaid     			|	0.01 				|
|	154				|	200 		|		pending			    |	overpaid     			|	46.00 				|



#Scenario: Renewal charge changes
#  When payment balance is underpaid
#  And renewal charge changes
#  Then payment balance will not change

#Scenario: Registration charge changes	
#  When payment balance is underpaid
#  And registration charge changes
#  Then payment balance will not change

##should this be a unit test?
#Scenario: Negative charge amount
#  When I select to enter payment
#  And I enter negative payment amount
#  And I enter payment details
#  And I confirm payment
#  Then the system will reject payment






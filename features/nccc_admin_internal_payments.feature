Feature:   nccc admin write offs
As an nccc admin user 
I want to be able write off small amounts of underpayment
So that waste carriers can be registered on the system

Background:
Given I am logged in as a finance admin user
  And I create an upper tier registration on behalf of a caller for payments
  And I have found a registrations payment details

@happy_days
Scenario: Write off underpayment
  When I select to enter a large writeoff
  And I writeoff equal to underpayment amount
  And I confirm write off
  Then payment status will be paid
  And payment history will be updated
  And payment balance will be 0.00

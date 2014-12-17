Feature:   nccc admin write offs

  As an nccc admin user
  I want to be able write off small amounts of underpayment
  So that waste carriers can be registered on the system

Background:
  Given I am logged in as an NCCC agency user
  And I create an upper tier registration on behalf of a caller who wants to pay offline
  And I make a note of the details
  And I remember the registration id
  And I finish the registration
  And I logout
  And I am logged in as an NCCC agency user
  And I have found a registrations payment details by name: Assisted Enterprises & Co
  And I logout
  And I am logged in as a finance admin user
  And I have found a registrations payment details by name: Assisted Enterprises & Co

@javascript @happy_days
Scenario: Write off underpayment
  When I select to enter a large writeoff
  And I writeoff equal to underpayment amount
  And I confirm write off
  Then payment status will be paid
  And payment history will show writeoff
  And payment balance will be 0.00

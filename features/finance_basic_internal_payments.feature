Feature: finance basic internal payments
As a finance basic user 
I want to be able to view waste carrier payment details
So that I can edit payment details

Background:
Given I am logged in as a finance basic user
  And I create an upper tier registration on behalf of a caller for payments
  And I provide valid credit card payment details on behalf of a caller
  And I have found a registrations payment details
  And the registration is valid for a small write off
#
# FIXME: Comment out test as unable to logout user from one role to another
#
#  And I change user to a nccc refunds user
  And I have found a registrations payment details

# Commented out as does not function as expected given the user signed in
#@happy_days
#Scenario: Write off underpayment
#  When I select to enter a small writeoff
#  And I writeoff equal to underpayment amount
#  And I confirm write off
#  Then payment status will be paid
#  And payment history will be updated
#  And payment balance will be 0.00

# Scenario: Financial adjustments - charge transactions
# When I correct an amount on the system
# # Then waste carriers payment details will be updated
# And payment history will be updated
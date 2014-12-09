Feature: new or renew question
As a waste carrier 
I want to be asked what I want to do
So I can either register as a waste carrier or renew my registration

Scenario: new registration
Given I am on the start page
When I choose a new registration
Then I will be directed to new registrations



# visit newOrRenew_path
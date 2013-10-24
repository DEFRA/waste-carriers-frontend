Feature: Validation of registrations

As the service owner
I want to ensure that registration data is validated
So that only valid registrations can be made and incomplete registrations are avoided

@javascript
@no-database-cleaner
Scenario: Missing business or organisation type
When I begin a registration
And I click "Next"
Then I should see an error with "Business or organisation type must be completed"

@javascript
@no-database-cleaner
Scenario: Missing Trading Name
When I begin a registration as an Individual
And I click "Next"
Then I should see an error with "Business, organisation or trading name must be completed"

@javascript
@no-database-cleaner
Scenario: Invalid Trading Name
When I begin a registration as an Individual
And I fill in company name with "%^&*"
And I click "Next"
Then I should see an error with "Business, organisation or trading name can only contain alpha numeric characters and be no longer than 35 characters"

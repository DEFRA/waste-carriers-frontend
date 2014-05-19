Feature: User Management

As an Administrator, I want to manage the accounts of internal agency users (including NCCC workers)
so that these users can access the service and create and manage registrations on behalf of businesses.

Administrators can create, modify and delete users.

@admin
Scenario: Login as Administrator
  Given I am an administrator
  When I log in as administrator
  Then I should see the user administration page

@admin
Scenario: Create a new user
  Given I am logged in as an administrator
  When I elect to create a new agency user
  And there is no such user yet
  And I fill in valid agency user details
  Then the user should have been created
  And I should see the user's details page

@admin
Scenario: Delete a user
  Given I am logged in as an administrator
  And there is a user to be deleted
  And I access the user administration page
  When I elect to delete the user
  And I confirm to delete the user
  Then the user should have been deleted

@admin
Scenario: Attempt to access user administration without being logged in
  Given I am an administrator
  When I am not logged in as an administrator
  And I access the user administration page
  Then I should be prompted to login as an administrator


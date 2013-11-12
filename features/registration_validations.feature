Feature: Validation of registrations

As the service owner
I want to ensure that registration data is validated
So that only valid registrations can be made and incomplete registrations are avoided

The registration form has the following fields to be entered by the user:
* Business or organisation type (dropdown select)
* Business, organisation or trading name
* Address:
  * Building name/number
  * Street (line 1)
  * Street (line 2)
  * Town/city
  * Postcode
* Contact Information:
  * Title (dropdown select)
  * First name
  * Last name
  * Job title
  * Phone number
  * Email address
* Declaration checkbox
* Email (for user account)
* password
* password confirmation


Scenario: Missing business or organisation type
  When I begin a registration
  And I click "Next"
  Then I should see an error with "Business or organisation type must be completed"

Scenario: Missing Trading Name
  When I begin a registration as an Individual
  And I click "Next"
  Then I should see an error with "Business, organisation or trading name must be completed"

Scenario: Invalid Trading Name
  When I begin a registration as an Individual
  And I fill in company name with "%^&*"
  And I click "Next"
  Then I should see an error with "Business, organisation or trading name can only contain alpha numeric characters and be no longer than 35 characters"

Scenario: Missing house number
  When I begin a registration as an Individual
  And proceed to the Address and Contact Details page
  And I click "Next"
  Then I should see an error with "Building name/number must be completed"


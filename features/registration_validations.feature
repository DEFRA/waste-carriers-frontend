@validations
Feature: Validation of registrations

As the service owner
I want to ensure that registration data is validated
So that only valid registrations can be made and incomplete registrations are avoided

The registration form has the following fields to be entered by the user:
* Business or organisation type (dropdown select)
* Business, organisation or trading name
* Address:
  * Building name or number
  * Street (line 1)
  * Street (line 2)
  * Town or city
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


#Scenario: Missing business or organisation type
#  When I begin a registration
#  And I click "Next"
#  Then I should see an error with "Business or organisation type must be completed"


#Scenario: Missing Trading Name
#  When I begin a registration as an Individual
#  And I click "Next"
#  Then I should see an error with "Business, organisation or trading name must be completed"


#Scenario: Invalid Trading Name
#  When I begin a registration as an Individual
#  And I fill in company name with "%^&*"
#  And I click "Next"
#  Then I should see an error with "Business, organisation or trading name can only contain alpha numeric characters and be no longer than 70 characters"


#Scenario: Missing mandatory fields on the Address and Contact Details page
#  When I begin a registration as an Individual
#  And proceed to the Address and Contact Details page
#  And I prepare to enter an address manually
#  And I click "Next"
#  #Then I should see an error with "Building name or number must be completed"
#  Then I should see an error with "Street must be completed"
#  Then I should see an error with "Town or city must be completed"
#  Then I should see an error with "Postcode must be completed"
#  Then I should see an error with "Title must be completed"
#  Then I should see an error with "First name must be completed"
#  Then I should see an error with "Last name must be completed"
#  Then I should see an error with "Phone number must be completed"
#  Then I should see an error with "Email address must be completed"

#Scenario: Invalid house number
#  When I begin a registration as an Individual
#  And proceed to the Address and Contact Details page
#  And I prepare to enter an address manually
#  And I fill in house number with "12£"
#  And I click "Next"
#  Then I should see an error with "Building name or number"

#Scenario: Valid house number - long house numbers (up to 35 characters) are allowed
#  When I begin a registration as an Individual
#  And proceed to the Address and Contact Details page
#  And I prepare to enter an address manually
#  And I fill in house number with "Very long house name here 123"
#  And I click "Next"
#  Then I should see no error with "Building name or number"


#Scenario: Invalid postcode
#  When I begin a registration as an Individual
#  And proceed to the Address and Contact Details page
#  And I prepare to enter an address manually
#  And I fill in postcode with "W1"
#  And I click "Next"
#  Then I should see an error with "Postcode"


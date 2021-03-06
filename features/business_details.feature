Feature: Business details validation rules
  Checks the validation messages are correct after each business type selection
  scenario

Background:
  Given I start a new registration

Scenario: Email screen confirmation
Given a lower tier registration is completed
Then I see the confirm email screen

Scenario: Validation message for non-selection on business type page
And I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: Who produces the waste validation non-selection - Sole trader
Given I am on the who produces the waste page for Sole trader
And I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: Construction validation non-selection - Sole trader
Given I am on the construction waste page for a Sole trader
When I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: CBD validation non-selection - Sole trader
Given I am on the CBD page for a Sole trader
When I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: Who produces the waste validation non-selection - Partnership
Given I am on the who produces the waste page for a Partnership
And I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: Construction validation non-selection - Partnership
Given I am on the construction waste page for a Partnership
When I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: CBD validation non-selection - Partnership
Given I am on the CBD page for a Partnership
When I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: Who produces the waste validation non-selection - Ltd Company
Given I am on the who produces the waste page for a Ltd Company
And I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: Construction validation non-selection - Ltd Company
Given I am on the construction waste page for a Ltd Company
When I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: CBD validation non-selection - Ltd Company
Given I am on the CBD page for a Ltd Company
When I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: Who produces the waste validation non-selection - Public body
Given I am on the who produces the waste page for a Public body
And I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: Construction validation non-selection - Public body
Given I am on the construction waste page for a Public body
When I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: CBD validation non-selection - Public body
Given I am on the CBD page for a Public body
When I continue without selecting an option
Then a validation message for none selection is displayed

Scenario: Validation messages ommission of trading name and postcode - Charity
Given I am on the business or organisation details page for a Charity
When I click find address without entering a trading name
Then a validation message for the trading name is displayed

Scenario: Validation messages ommission of trading name and postcode - Authority
Given I am on the business or organisation details page for an Authority
When I click find address without entering a trading name
Then a validation message for the trading name is displayed

#--------------------------------------------------------------------------------

#Pre-population of business Owner details

Scenario: Sole trader business owner details are pre-populated
Given I am registering as a sole trader
And I am a carrier dealer
And I provide my company name
And I autocomplete my business address
And I provide my personal contact details
Then Business owner details are pre-populated

#-------------------------------------------------------------------------------

# Second Contact details

Scenario: Check "Who should we write to?" page is pre-populated with relevant details
Given I am registering as a sole trader
And I am a carrier dealer
And I provide my company name
And I autocomplete my business address
And I provide my personal contact details
Then The Who Should We Write To page is pre-populated with relevant details

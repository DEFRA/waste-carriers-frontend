Feature: IR registrations - Assisted changes business type
As an NCCC User I want to be able to Search for an Existing IR Number and Edit the Org Type from
LTD to Partnership Ensuring that I am required to enter Key People to the record of the Organisation.
Prompting a fee of 154.00


@javascript
Scenario: Agency assisted change LTD to Partnership
Given a "LTD_UT_online_complete" upper tier registration paid for by "World Pay" with 0 copy cards
Given I have signed in as an Environment Agency user
Then I search for the following organisation "LTD UT Company"
Then Edit The Registration
Then I click Edit what you told us
Then I change business type to partnership
And the smart answers keep me in Upper tier
And I don't change waste carrier type
And I don't change business details
And I don't change contact details
And I confirm my postal address
And I add the following people:
| first_name | last_name | dob_day | dob_month | dob_year |
| James      | Hunt      | 29      | 08        | 1947     |
Then I click continue
And no key people in the organisation have convictions
When I confirm the declaration
Then I should be shown the total cost "154.00"

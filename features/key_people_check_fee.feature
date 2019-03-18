Feature: Key People Add with full Fee
  As a waste carrier
  I want to be able to edit my registration
  So that I can update my Key People with the Envrionment agency to continue to be registered as a waste carrier paying the correct fee

    @javascript
    Scenario: Agency assisted Partner add relevant people
    Given a "PT_UT_online_complete" upper tier registration paid for by "World Pay" with 0 copy cards
    Given I have signed in as an Environment Agency user
    Then I visit the edit registration page
    When I edit my business owner details
    And I add the following people:
    | first_name | last_name | dob_day | dob_month | dob_year |
    | James      | Hunt      | 29      | 08        | 1947     |
    Then I click continue
    And no key people in the organisation have convictions
    When I confirm the declaration
    Then I should be shown the total cost "154.00"

    @javascript
    Scenario: Agency assisted Partner Delete then add another partner
    Given a "PT_UT_online_complete" upper tier registration paid for by "World Pay" with 0 copy cards
    Given I have signed in as an Environment Agency user
    Then I visit the edit registration page
    When I edit my business owner details
    Then Delete first relevant person
    And I add the following people:
    | first_name | last_name | dob_day | dob_month | dob_year |
    | James      | Hunt      | 29      | 08        | 1947     |
    Then I click continue
    And no key people in the organisation have convictions
    When I confirm the declaration
    Then I am redirected to agency user home page with no fee

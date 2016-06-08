Feature: Key People Add with full Fee
  As a waste carrier
  I want to be able to edit my registration
  So that I can update my Key People with the Envrionment agency to continue to be registered as a waste carrier paying the correct fee

    @javascript
    Scenario: LTD company add Director
    Given a "LTD_UT_online_complete" upper tier registration paid for by "World Pay" with 0 copy cards
    And I wait for 2 seconds for these actions to be finalised
    When I am logged in as waste carrier user 'ltd_ut@example.org'
    Given The edit link is available
    Then I click the Edit Registration link
    When I edit my business owner details
    And I add the following people:
    | first_name | last_name | dob_day | dob_month | dob_year |
    | James      | Hunt      | 29      | 08        | 1947     |
    Then I click continue
    And no key people in the organisation have convictions
    When I confirm the declaration
    Then I should be shown the total cost "154.00"

    @javascript
    Scenario: Public Body add CEO
    Given a "PB_UT_online_complete" upper tier registration paid for by "World Pay" with 0 copy cards
    And I wait for 2 seconds for these actions to be finalised
    When I am logged in as waste carrier user 'pb_ut@example.org'
    Given The edit link is available
    Then I click the Edit Registration link
    When I edit my business owner details
    And I add the following people:
    | first_name | last_name | dob_day | dob_month | dob_year |
    | James      | Hunt      | 29      | 08        | 1947     |
    Then I click continue
    And no key people in the organisation have convictions
    When I confirm the declaration
    Then I should be shown the total cost "154.00"

    @javascript
    Scenario: Partnership add Partner
    Given a "PT_UT_online_complete" upper tier registration paid for by "World Pay" with 0 copy cards
    And I wait for 2 seconds for these actions to be finalised
    When I am logged in as waste carrier user 'pt_ut@example.org'
    Given The edit link is available
    Then I click the Edit Registration link
    When I edit my business owner details
    And I add the following people:
    | first_name | last_name | dob_day | dob_month | dob_year |
    | James      | Hunt      | 29      | 08        | 1947     |
    Then I click continue
    And no key people in the organisation have convictions
    When I confirm the declaration
    Then I should be shown the total cost "154.00"

    @javascript
    Scenario: Agency assisted Partner add relevant people
    Given a "PT_UT_online_complete" upper tier registration paid for by "World Pay" with 0 copy cards
    Given I have signed in as an Environment Agency user
    Then I search for the following organisation "PT UT Company"
    Then Edit The Registration
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
    Then I search for the following organisation "PT UT Company"
    Then Edit The Registration
    When I edit my business owner details
    Then Delete first relevant person
    And I add the following people:
    | first_name | last_name | dob_day | dob_month | dob_year |
    | James      | Hunt      | 29      | 08        | 1947     |
    Then I click continue
    And no key people in the organisation have convictions
    When I confirm the declaration
    Then We are redirected to agency user home page with no fee

    @javascript
    Scenario: Partnership Delete then add another Partner
    Given a "PT_UT_online_complete" upper tier registration paid for by "World Pay" with 0 copy cards
    And I wait for 2 seconds for these actions to be finalised
    When I am logged in as waste carrier user 'pt_ut@example.org'
    Given The edit link is available
    Then I click the Edit Registration link
    When I edit my business owner details
    Then Delete first relevant person
    And I add the following people:
    | first_name | last_name | dob_day | dob_month | dob_year |
    | James      | Hunt      | 29      | 08        | 1947     |
    Then I click continue
    And no key people in the organisation have convictions
    When I confirm the declaration
    Then We are redirected to account holder home page with no fee

Feature: Lower tier

  As a lower tier waste carrier
  I want to complete the lower tier form
  So that my registration is processed by the Environment Agency

  Background:
    Given I have been funneled into the lower tier path
    And I provide my company name

  Scenario: Autocomplete address
    Given I autocomplete my business address
    And I provide my personal contact details
    And I provide a postal address
    And I check the declaration
    And I provide my email address and create a password
    When I confirm account creation via email
    Then I am registered as a lower tier waste carrier

  Scenario: Autocomplete with unrecognised postcode
    Given I want my business address autocompleted but I provide an unrecognised postcode
    When I try to select an address
    Then no address suggestions will be shown
    But I can edit this postcode
    And add my address manually if I wanted to

  Scenario: Manually enter UK address
    Given I enter my business address manually
    And I provide my personal contact details
    And I provide a postal address
    And I check the declaration
    And I provide my email address and create a password
    When I confirm account creation via email
    Then I am registered as a lower tier waste carrier

  Scenario: Foreign waste carrier
    Given I enter my foreign business address manually
    And I provide my personal contact details
    And I provide a postal address
    And I check the declaration
    And I provide my email address and create a password
    When I confirm account creation via email
    Then I am registered as a lower tier waste carrier

  Scenario: Must confirm email address before appearing on the Public Register
    Given I autocomplete my business address
    And I provide my personal contact details
    And I provide a postal address
    And I check the declaration
    And I provide my email address and create a password
    When I wait for 2 seconds for these actions to be finalised
    Then My company name should not appear on the Public Register
    When I confirm account creation via email
    Then My company name should appear on the Public Register

Feature: Lower tier

  As a lower tier waste carrier
  I want to complete the lower tier form
  So that my registration is left with the Environment Agency

  Background:
    Given I have been funneled into the lower tier path
      And I provide my company name

  Scenario: Autocomplete address
    Given I enter my address details by providing a postcode first
      And I provide my personal contact details
      And I check the declaration
      And I provide email and password details
    When I confirm my account creation via email
    Then my lower tier registration is active

  Scenario: Manually-enter address
    Given I enter my address manually
      And I provide my personal contact details
      And I check the declaration
      And I provide email and password details
    When I confirm my account creation via email
    Then my lower tier registration is active

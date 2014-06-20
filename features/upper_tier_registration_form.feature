Feature: Upper tier

  As an upper tier waste carrier
  I want to complete the upper tier form
  So that my registration is processed with the Environment Agency

  Background:
    Given I have been funneled into the upper tier path
      And I am a carrier dealer
      And I provide my company name

  Scenario: Autocomplete address
    Given I autocomplete my business address
      And I provide my personal contact details
      And I check the declaration
      And I provide my email address and create a password
    When I confirm account creation via email
    Then I am registered as an upper tier waste carrier

  Scenario: Autocomplete with unrecognised postcode
    Given I want my business address autocompleted but I provide an unrecognised postcode
    When I try to select an address
    Then no address suggestions will be shown
      But I can edit this postcode
      And add my address manually if I wanted to

  Scenario: Manually enter UK address
    Given I enter my business address manually
      And I provide my personal contact details
      And I check the declaration
      And I provide my email address and create a password
    When I confirm account creation via email
    Then I am registered as an upper tier waste carrier

  Scenario: Foreign waste carrier
    Given I enter my foreign business address manually
      And I provide my personal contact details
      And I check the declaration
      And I provide my email address and create a password
    When I confirm account creation via email
    Then I am registered as an upper tier waste carrier

  # TODO ltd company version asks for companies house number and directors
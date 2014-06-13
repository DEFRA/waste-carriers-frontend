Feature: Companies House
  As an NCCC worker
  I want the system to cross check a company with companies house data
  So that I can ensure that valid companies are registering as a waste carrier

  Background:
    Given I am registering as a limited company
      And I am on the upper tier business details page
      And I enter my company name and address

  @happy_days
  Scenario: Active company
    Given I enter an active company number
    When I click to advance
    Then I proceed to the next wizard step

  Scenario: Inactive company
    Given I enter an inactive company number
    When I click to advance
    Then I am told the company is not active
      And I remain on the upper tier business details page

  Scenario: Company not found
    Given I enter a company number which does not exist
    When I click to advance
    Then I am told the company was not found
      And I remain on the upper tier business details page

  Scenario: Left blank
    Given I leave the company number blank
    When I click to advance
    Then I am told the company number needs to be filled in
      And I remain on the upper tier business details page

  Scenario: Service unavailable
    Given I enter an active company number
      But the external service is unavailable
    When I click to advance
    Then I am told to retry when the external service is available
      And I remain on the upper tier business details page



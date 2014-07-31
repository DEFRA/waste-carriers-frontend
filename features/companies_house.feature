Feature: Companies House
  As an NCCC worker
  I want the system to cross check a company with companies house data if it is an upper tier application
  So that I can ensure that valid companies are registering as a waste carrier

  If the Companies House Web service is unavailable or there is some other error, waste carriers will not be able to
  proceed. Such scenarios are covered in a separate RSpec (it was difficult to get WebMock working with Cucumber).

  Background:
    Given I am registering as a limited company

  @happy_days
  @vcr
  Scenario: Active upper tier company
    Given I am on the business details page as an upper tier
    And I enter an active company number
    And I enter my company name and address
    When I click to advance
    Then I proceed to the next wizard step

  @happy_days
  @vcr
  Scenario: Active lower tier company
    Given I am on the business details page as an lower tier
    Then I am not asked for my company number

  @vcr
  Scenario: Inactive company
    Given I am on the business details page as an upper tier
    And I enter an inactive company number
    And I enter my company name and address
    When I click to advance
    Then I am told the company is not active
      And I remain on the upper tier business details page

  @vcr
  Scenario: Company not found
    Given I am on the business details page as an upper tier
    And I enter a company number which does not exist
    And I enter my company name and address
    When I click to advance
    Then I am told the company was not found
      And I remain on the upper tier business details page

  Scenario: Left blank
    Given I am on the business details page as an upper tier
    And I leave the company number blank
    And I enter my company name and address
    When I click to advance
    Then I am told the company number needs to be filled in
      And I remain on the upper tier business details page



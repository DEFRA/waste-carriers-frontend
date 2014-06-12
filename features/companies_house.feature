Feature: Companies House
  As an NCCC worker
  I want the system to cross check a company with companies house data
  So that I can ensure that valid companies are registering as a waste carrier

  Scenarios can be split into four main categories, valid, invalid, unavailable and company number missing. Any check not passed as valid will stop navigation onto contact details page

  @happy_days
  Scenario Outline: Successful lookup of valid company details
    Given I'm on Upper Tier Business details page
      And I enter my company name and address
      And I enter my <company_number> in the relevant field
    When I press the 'Company Check' button
    Then I see a message that the company number is valid
      And I can proceed to the contact details page

  Examples:
  |	company_number	|
  |	00996877		|
  |	67543213		|
  |	7656223			|
  |	NI898346		|
  |	SC875432		|

  Scenario: Lookup of invalid company details
    Given I'm on Upper Tier Business details page
      And I enter my company name and address
      And I enter my <company_number> in the relevant field
    When I press the 'Company Check' button
    Then I see a message that the company number is invalid
      And I can't proceed to the contact details page

    Examples:
    |	company_number	|
    |	00733662		|
    |	67543213		|
    |	7656223			|
    |	NI898346		|
    |	SC875432		|
    |	01070877		|
    |	07197040		|
    |	01812800		|
    |	SC209426		|

  Scenario: Service not available
    Given I'm on Upper Tier Business details page
    When a companies house number is entered
      But the connection to companies house is lost
    Then an error message is displayed to the system user

  Scenario: Ignoring company check
    Given I'm on Upper Tier Business details page
      And I enter my company name and address
      But I leave the company number field blank
    When I press the 'Company Check' button
    Then I see a message that the company number is invalid
      And I can't proceed to the contact details page





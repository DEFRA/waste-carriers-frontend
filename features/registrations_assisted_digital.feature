Feature: Registrations - Assisted Digital

  As a worker in the NCCC contact centre
  I want to be able to register on behalf of an applicant who gives me their details over the phone
  So that I do not have to send them a paper form

  For assisted digital users the system computes a random six-letter access code
  which the user needs for further changes via the phone.

  Background:
    Given I am logged in as an NCCC agency user

  Scenario: Lower tier
    When I create a lower tier registration on behalf of a caller
    Then I should see the Confirmation page
      And the registration confirmation email should not be sent
      And when I access the print page
      And the print page contains the six-digit access code for the user

  Scenario: Upper tier
    When I create an upper tier registration on behalf of a caller
    Then I should see the Confirmation page
      And the registration confirmation email should not be sent
      And the print page contains the six-digit access code for the user

  Scenario: Valid registration on behalf of a caller
    Given I am logged in as an NCCC agency user
    And I start a new registration
    Then I should see the Business or Organisation Details page
    And I select business or organisation type "Sole trader"
    And I fill in "Business, organisation or trading name" with "Joe Bloggs assisted"
    And I click "Next"
    And I fill in valid contact details without email
    And I click "Next"
    And I select the declaration checkbox
    And I click "Next"
    And I click "Next"
    Then I should see the Confirmation page
    And the registration confirmation email should not be sent
    And when I access the print page
    Then the print page contains the six-digit access code for the user


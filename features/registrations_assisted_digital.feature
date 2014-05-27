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

  @assisted_digital
  Scenario: Valid registration on behalf of a caller
    Given I start a new registration on behalf of a caller
      And the caller provides initial answers for the lower tier
      And the caller provides his business organisation details
      And the caller provides his contact details
      And the caller declares the information provided is correct
      And the user confirms his account details
    Then I should see the Confirmation page
      And the registration confirmation email should not be sent
      And when I access the print page
      And the print page contains the six-digit access code for the user

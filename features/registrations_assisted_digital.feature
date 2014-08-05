@assisted_digital
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
      And the print page contains the six-digit access code for the user
      And the lower tier waste carrier registration id
      But the registration confirmation email should not be sent

  @worldpay
  Scenario: Upper tier
    When I create an upper tier registration on behalf of a caller for payments
      And I provide valid credit card payment details on behalf of a caller
    Then I see the six-character access code for the user
      And the upper tier waste carrier registration id
      But the registration confirmation email should not be sent

  Scenario: Upper tier offline payment
    When I create an upper tier registration on behalf of a caller who wants to pay offline
      And I see the payment details to tell the customer
    Then I see the six-character access code for the user
      And the upper tier waste carrier registration id
      But the registration confirmation email should not be sent

  Scenario: Valid registration on behalf of a caller
    Given I start a new registration on behalf of a caller
      And the caller provides initial answers for the lower tier
      And the caller provides his business organisation details
      And the caller provides his contact details
      And the caller declares the information provided is correct
      And the user confirms his account details
    Then I should see the Confirmation page
      And the print page contains the six-digit access code for the user
      But the registration confirmation email should not be sent

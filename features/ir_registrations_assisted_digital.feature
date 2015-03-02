
Feature: ir registrations assisted digital

  As a agency user
  I want to be able to renew ir registrations from the old IR system, on behalf of external users
  So that they can continue to be registered as a waste carriers

Background: Environment agency user is logged into system
Given I have signed in as an Environment Agency user
And have chosen to renew a customers existing licence

#Test updated should pass when #83644968 'IR renewals using NCCC login result in incorrect charge' is resolved
@wip
Scenario: IR registrations - AD - Limited company changes business details should be charged renewal fee
  Given I am renewing a valid CBD IR registration for limited company
  When I only change business details
  Then I should be shown the total cost is the charge amount and renewal amount "105.00"
  And have the option to pay by Credit or Debit card or by bank transfer

#Test updated should pass when #83644968 'IR renewals using NCCC login result in incorrect charge' is resolved
@wip
Scenario: IR registrations - AD - Limited company changes business name should be charged renewal fee
  Given I am renewing a valid CBD IR registration for limited company
  When I only change business name
  Then I should be shown the total cost is the charge amount and renewal amount "105.00"
  And have the option to pay by Credit or Debit card or by bank transfer

#Test updated should pass when #83644968 'IR renewals using NCCC login result in incorrect charge' is resolved
@javascript @happy_days @wip
Scenario: Assisted Digital IR registrations, No convictions, Online payment
  Given I am registering an IR registration for a Sole trader and pay by credit card
  Then a renewal fee will be charged
  And the callers registration should be complete when payment is successful

#Test updated should pass when #83644968 'IR renewals using NCCC login result in incorrect charge' is resolved
@javascript @wip
Scenario: Assisted Digital IR registrations, Convictions, Online payment
   Given I am registering an IR registration for a Public body and pay by credit card
   Then a renewal fee will be charged
   And the callers registration should be pending convictions checks when payment is successful

#Test updated should pass when #83644968 'IR renewals using NCCC login result in incorrect charge' is resolved
@wip
Scenario: Assisted Digital IR registrations, No Convictions, Offline payment
  Given I am registering an IR registration for a Partnership and pay by bank transfer
   Then a renewal fee will be charged
   And the callers registration should be pending payment
   And the correct renewal charge should be shown

#Test updated should pass when #83644968 'IR renewals using NCCC login result in incorrect charge' is resolved
@javascript @wip
Scenario: Assisted Digital IR registrations, Convictions, Offline payment
  Given I am registering an IR registration for a limited company with convictions and pay by bank transfer
  Then a renewal fee will be charged
  And the callers registration should be pending convictions checks when payment is successful

#Test updated should pass when #83644968 'IR renewals using NCCC login result in incorrect charge' is resolved
@javascript @wip
Scenario: IR registrations - AD - Limited company changes waste carrier type and pays by credit card
  Given I am registering an IR registration for a limited company changing waste carrier type and pay by credit card
  Then there will be a renewal and edit amount charged
  And the callers registration should be complete when payment is successful
  And the correct renewal charge should be shown

#Test updated should pass when #83644968 'IR renewals using NCCC login result in incorrect charge' is resolved
@wip
Scenario: IR registrations - AD - Sole Trader changes waste carrier type with convictions and pays by bank transfer
  Given I am registering an IR registration for a Sole trader changing waste carrier type with convictions and pay by bank transfer
  Then there will be a renewal and edit amount charged
  And the callers registration should be pending payment
  And the correct renewal and edit charge should be shown




Feature: Editing registrations

As a waste carrier
I want to be able to change my registration details
so that I can keep fulfilling my obligations as a waste carrier

Scenario: Waste Carrier changing his registration
  Given I have registered before and have an active registration
  And I am logged in
  When I edit my registration
  Then my registration has been updated

Scenario: Agency user changing a registration on behalf of a waste carrier
  Given I am logged in as an agency user
  When I select and edit the registration
  Then the registration has been updated



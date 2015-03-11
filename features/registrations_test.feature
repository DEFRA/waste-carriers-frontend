Feature: Registration and Payment export

  Only an agency user can export registrations and payments

Scenario: An unauthenticated user cannot export
  When I open the registrations export page directly
  Then I see the agency user login page
  When I open the payments export page directly
  Then I see the agency user login page

Scenario: An Admin user cannot export
  Given I am logged in as an administrator
  When I open the registrations export page directly
  Then I see the agency user login page
  When I open the payments export page directly
  Then I see the agency user login page

Scenario: An External user cannot export
  Given I am logged in as a waste carrier
  When I open the registrations export page directly
  Then I see the agency user login page
  When I open the payments export page directly
  Then I see the agency user login page

Scenario: An Agency user can export
  Given I am logged in as an NCCC agency user
  When I open the registrations export page directly
  Then I can see the registrations export page
  When I open the payments export page directly
  Then I can see the payments export page

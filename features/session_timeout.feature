Feature: Session timeout

Sessions should expire after a certain duration or time of nactivity for security reasons, 
particularly for internal or adminstrative functions/purposes.

There is no inactivity timeout during registration. There is however a session inactivity timeout for logged-in waste carriers.

There is a session inactivity timeout for Waste Carriers.

There is no session inactivity timeout for internal users (a.k.a. agency users, NCCC), due to their expected work patterns.

There is a session inactivity timeout for administrators.

There is a total session timeout of 8 hours for logged in users.

Note: These timeouts can be configured in the Rails application configuration - see parameters 
  config.app_session_inactivity_timeout
  config.app_session_total_timeout 
in application.rb.


Scenario: Waste carrier registration does not expire due to inactivity
  Given I have started my registration
  When I do nothing for more than 20 minutes
  And I try to proceed with my unfinished registration
  Then I can still proceed


Scenario: Waste carrier registration does not expire due to total session duration
  Given I have started my registration
  And I keep working on my registration for more than 8 hours
  Then I can continue with my registration


Scenario: Logged in waste carrier session expires due to inactivity
  Given I am logged in as a waste carrier
  When I do nothing for more than 20 minutes
  And I try to continue with my registrations
  Then my waste carrier session has expired


Scenario: Administration session expires due to inactivity
  Given I am logged in as an administrator
  When I do nothing for more than 20 minutes
  And I want to continue with my administration tasks
  Then I am informed that my session has expired


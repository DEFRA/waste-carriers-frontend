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
  Given I have started a new registration and gone as far as the Waste From Other Businesses step
  When I do nothing for more than 20 minutes
  Then I can still continue past the Waste From Other Businesses step

Scenario: Waste carrier registration does not expire due to total session duration
  Given I have started a new registration and gone as far as the Waste From Other Businesses step
  And I keep working on my registration for more than 8 hours
  Then I can still continue past the Waste From Other Businesses step

Scenario: Administration session expires due to inactivity
  Given I am logged in as an administrator
  When I do nothing for more than 20 minutes
  And I want to continue with my administration tasks
  Then I am informed that my session has expired

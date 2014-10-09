Feature: Session termination

As a user I do not want my data to be available in the browser anymore
after I have finished my registration session
so that my data is secure.

After the user has completed his registration and finished his session,
it should not be possible anymore to access the registration and session data.

Scenario: Clicking Back after finishing the registration session
  Given I have completed my lower tier registration
  And I have finished my registration session
  When I attempt to access the previous page
  Then my registration data is not shown anymore

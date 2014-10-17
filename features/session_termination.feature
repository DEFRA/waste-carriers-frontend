Feature: Session termination

As a user I do not want my data to be available in the browser anymore
after I have finished my registration session
so that my data is secure.

Even after the registration has been saved in the database, the user should not be able to 
(accidentally or otherwise) edit the registration by accessing the registration flow pages
which edit the registration.

After the user has completed his registration and finished his session,
it should not be possible anymore to access the registration and session data.

Scenario: Clicking Back after finishing the registration session
  Given I have completed my lower tier registration
  And I have confirmed my user account
  And I have finished my registration session
  When I attempt to access the previous page
  Then my registration data is not shown anymore

Scenario: Going back after completing (saving) the registration
  Given I have completed my lower tier registration
  When I attempt to access the confirmation page
  Then I am informed that I have to login again to change my registration


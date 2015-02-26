Feature: Tests the assistance provided to users regarding their account

# Section 1: Test which links appear on the normal sign-in page for different
#            user types.

Scenario: The User sign-in page should contain links for password reset and account confirmation
          along with the NCCC contact number for forgotten email addresses.
  Given I am a Waste Carrier and already have an account with a confirmed email address
   When I go to my sign-in page
   Then there should be a link to request password reset instructions
    And there should be a link to request account confirmation instructions
    And the NCCC contract number should be shown

Scenario: The Agency User sign-in page should contain links for password reset and account unlock.
  Given I am an Agency User
   When I go to my sign-in page
   Then there should be a link to request password reset instructions
    And there should be a link to request account unlock instructions

Scenario: The Admin sign-in page should contain links for password reset and account unlock.
  Given I am an Admin
   When I go to my sign-in page
   Then there should be a link to request password reset instructions
    And there should be a link to request account unlock instructions



# Section 2: Test where a Waste Carrier gets redirected to after using the links
#            on the normal sign-in page.

Scenario: When a new User (incorrectly) requests Password Reset instructions from the normal
          sign-in page, they should be returned to the normal sign-in page.
  Given I am a Waste Carrier visiting the service for the first time
   When I go to my sign-in page
    And I request Password Reset instructions
   Then I should be sent to the normal User Sign In page

Scenario: When a new User (incorrectly) requests Account Confirmation instructions from the normal
          sign-in page, they should be returned to the normal sign-in page.
  Given I am a Waste Carrier visiting the service for the first time
   When I go to my sign-in page
    And I request Account Confirmation instructions
   Then I should be sent to the normal User Sign In page

Scenario: When an existing User requests Password Reset instructions from the normal
          sign-in page, they should be returned to the normal sign-in page.
  Given I am a Waste Carrier and already have an account with a confirmed email address
   When I go to my sign-in page
    And I request Password Reset instructions
   Then I should be sent to the normal User Sign In page

Scenario: When an existing User requests Account Confirmation instructions from the
          normal sign-in page, they should be returned to the normal sign-in page.
  Given I am a Waste Carrier and already have an account with a confirmed email address
   When I go to my sign-in page
    And I request Account Confirmation instructions
   Then I should be sent to the normal User Sign In page



# Section 3: Test which links appear on the mid-registration sign-in page, and
#            the behaviour of the app when the user clicks on those links.

Scenario: When an existing User makes a new registration, they should be shown the
          mid-registration sign-in page (not the sign-up page)
  Given I am a Waste Carrier and already have an account with a confirmed email address
    But I am not currently signed-in to the service
   When I make a new registration and progress as far as accepting the Declaration
   Then I should be sent to the mid-registration User Sign In page
    And there should be a link to request password reset instructions
    And there should be a link to request account confirmation instructions
    But the NCCC contract number should not be shown

Scenario: An existing user should be able to request and provide a new password mid-registration,
          then successfully complete their second registration.
  Given I am a Waste Carrier and already have an account with a confirmed email address
    But I am not currently signed-in to the service
   When I make a new registration and progress as far as accepting the Declaration
   Then I should be sent to the mid-registration User Sign In page
   When I request Password Reset instructions
   Then I should be sent to the mid-registration User Sign In page
   When I update my password
    And I should be able to continue with my registration

Scenario: An existing user who has already confirmed their email should be able to request email
          confirmation instructions mid-registration, then successfully complete their second registration.
  Given I am a Waste Carrier and already have an account with a confirmed email address
    But I am not currently signed-in to the service
   When I make a new registration and progress as far as accepting the Declaration
   Then I should be sent to the mid-registration User Sign In page
   When I request Account Confirmation instructions
   Then I should be sent to the mid-registration User Sign In page
    And I should recieve an email informing me that my email address is already confirmed and that I should continue with the registration
    And I should be able to continue with my registration

Scenario: An existing user who hasn't confirmed their email should be able to request and perform email
          confirmation instructions mid-registration, then successfully complete their second registration.
  Given I am a Waste Carrier visiting the service for the first time
   When I complete my first registration but do not confirm my email address
    And I delete all of my emails
    And I make a new registration and progress as far as accepting the Declaration
   Then I should be sent to the mid-registration User Sign In page
   When I request Account Confirmation instructions
   Then I should be sent to the mid-registration User Sign In page
    And I should recieve an email containing account confirmation instructions
   When I confirm my my account, then close the browser window
    And I should be able to continue with my registration



# Section 4: Test where an Agency User gets redirected to after using the links
#            on the sign-in page.

Scenario: When an Agency User requests Password Reset instructions from the normal
          sign-in page, they should be returned to the normal sign-in page.
  Given I am an Agency User
   When I go to my sign-in page
    And I request Password Reset instructions
   Then I should be sent to the normal Agency User Sign In page

Scenario: When an Agency User requests Account Unlock instructions from the normal
          sign-in page, they should be returned to the normal sign-in page.
  Given I am an Agency User
   When I go to my sign-in page
    And I request Account Unlock instructions
   Then I should be sent to the normal Agency User Sign In page



# Section 5: Test where an Admin gets redirected to after using the links on the
#            sign-in page.

Scenario: When an Admin requests Password Reset instructions from the normal sign-in
          page, they should be returned to the normal sign-in page.
  Given I am an Admin
   When I go to my sign-in page
    And I request Password Reset instructions
   Then I should be sent to the normal Admin Sign In page

Scenario: When an Admin requests Account Unlock instructions from the normal sign-in
          page, they should be returned to the normal sign-in page.
  Given I am an Admin
   When I go to my sign-in page
    And I request Account Unlock instructions
   Then I should be sent to the normal Admin Sign In page

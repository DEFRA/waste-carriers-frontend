@authentication
Feature: Authentication

Generally, the application supports three types of users:
1) External users (Waste Carriers, Brokers or Dealers)
2) Internal agency users (NCCC and others)
3) Administrators

External users can can register (and sign up during that registration process and flow), and sign in to amend their own registration.
However they now do so through the waste carriers front office application.

Internal users can create and amend registrations on behalf of other users (e.g. for Assisted Digital purposes).
Internal users can revoke or delete registrations, if authorised to do so.
Internal users can search and review registrations.

Administrators can create and manage other internal users.

Users can change their password (once signed in), or have their password reset if they have forgotten their password.

Internal and administrative functions can only be accessed from known locations (registered IP addresses) and via a special "admin" URL subdomain. Administrative functions will have special URLs such as "/agency_users/*" or "/admins/*".

Scenario Outline: Lock a user account
  Given an <user_type> exists and has an activated, non-locked account
  When somebody visits the <user_type> Sign In page
  When the maximum number of invalid login attempts is exceeded for the <user_type> account
  Then the <user_type> should receive an email containing a link which unlocks the account

  Examples:
    | user_type     |
    | Internal User |
    | Admin User    |

Scenario Outline: Unlock a user account
  Given an <user_type> exists and has an activated, non-locked account
  When somebody visits the <user_type> Sign In page
  When the maximum number of invalid login attempts is exceeded for the <user_type> account
  Then the <user_type> should receive an email containing a link which unlocks the account
  Then the user should see a login account unlocked successfully page

  Examples:
    | user_type     |
    | Internal User |
    | Admin User    |

Scenario Outline: It should not be possible to enumerate accounts using the password reset page and known email addresses
  Given an <user_type> exists and has an activated, non-locked account
  When somebody visits the <user_type> Forgot Password page
  And completes the request using the email address of a valid <user_type>
  Then they should be redirected to the login page, but not told if the email address they supplied was known or unknown
  And the <user_type> should receive an email containing a link which allows the password to be reset

  Examples:
    | user_type     |
    | Internal User |
    | Admin User    |

Scenario Outline: It should not be possible to enumerate accounts using the password reset page and guessed email addresses
  Given an <user_type> exists and has an activated, non-locked account
  When somebody visits the <user_type> Forgot Password page
  And completes the request using a guessed email address
  Then they should be redirected to the login page, but not told if the email address they supplied was known or unknown

  Examples:
    | user_type     |
    | Internal User |
    | Admin User    |

Scenario Outline: It should not be possible to enumerate accounts using the account unlock page and known email addresses
  Given an <user_type> exists and has an activated, non-locked account
  When the maximum number of invalid login attempts is exceeded for the <user_type> account
  And somebody visits the <user_type> Send Unlock Instructions page
  And completes the request using the email address of a valid <user_type>
  Then they should be redirected to the login page, but not told if the email address they supplied was known or unknown
  And the <user_type> should receive an email containing a link which unlocks the account
  And the <user_type> account 'locked' status should be unlocked

  Examples:
    | user_type     |
    | Internal User |
    | Admin User    |

Scenario Outline: It should not be possible to enumerate accounts using the account unlock page and guessed email addresses
  Given an <user_type> exists and has an activated, non-locked account
  When somebody visits the <user_type> Send Unlock Instructions page
  And completes the request using a guessed email address
  Then they should be redirected to the login page, but not told if the email address they supplied was known or unknown

  Examples:
    | user_type     |
    | Internal User |
    | Admin User    |

Scenario: It should not be possible to enumerate accounts by requesting account confirmation using a known email address
  Given an External User exists and has an activated, non-locked account
  When somebody visits the Resend Confirmation Instructions page
  And completes the request using the email address of a valid External User
  Then they should be redirected to the login page, but not told if the email address they supplied was known or unknown

Scenario: It should not be possible to enumerate accounts by requesting account confirmation using a guessed email address
  Given an External User exists and has an activated, non-locked account
  When somebody visits the Resend Confirmation Instructions page
  And completes the request using a guessed email address
  Then they should be redirected to the login page, but not told if the email address they supplied was known or unknown

Scenario: It should not be possible to enumerate accounts by requesting account confirmation using a known but unconfirmed email address
  Given an External User exists but has not confirmed their account
  When somebody visits the Resend Confirmation Instructions page
  And completes the request using the email address of a valid External User
  Then they should be redirected to the login page, but not told if the email address they supplied was known or unknown
  And the External User should receive an email allowing them to confirm their account

@wip
Scenario: Log in as admin from the public URL
  When the user tries to access the internal admin login URL from the public domain
  Then the page is not found

@wip
Scenario: Log in as agency user from the public URL
  When the user tries to access the internal agency login URL from the public domain
  Then the page is not found

@wip
Scenario: Log in as admin from the admin URL
  When the user tries to access the internal admin login URL from the admin domain
  Then the admin login page is shown

@wip
Scenario: Log in as agency user from the admin URL
  When the user tries to access the internal agency login URL from the admin domain
  Then the agency user login page is shown

@wip
Scenario: Log in as waste carrier from the admin URL
  When the user tries to access the user login URL from the internal admin domain
  Then the page is not found

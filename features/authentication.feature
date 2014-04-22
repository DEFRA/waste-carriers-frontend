Feature: Authentication

Generally, the application supports three types of users:
1) External users (Waste Carriers, Brokers or Dealers)
2) Internal agency users (NCCC and others)
3) Administrators

External users can can register (and sign up during that registration process and flow), and sign in to amend their own registration.

Internal users can create and amend registrations on behalf of other users (e.g. for Assisted Digital purposes).
Internal users can revoke or delete registrations, if authorised to do so.
Internal users can search and review registrations.

Administrators can create and manage other internal users.

Users can change their password (once signed in), or have their password reset if they have forgotten their password.

Internal and administrative functions can only be accessed from known locations (registered IP addresses) and via a special 'admin' URL subdomain (such as 'admin.wastecarriers.service.gov.uk' vs. 'www.wastecarriers.service.gov.uk'). Administrative functions will have special URLs such as '/agency_users/*'' or '/admins/*'.


Scenario: Log in successfully as Waste Carrier
  Given there is an activated user
  When the user visits the login page
  And enters valid credentials
  Then the user should be logged in successfully


Scenario: Log in as Waste Carrier - invalid password
  Given there is an activated user
  When the user visits the login page
  And enters invalid credentials
  Then the user should see a login error




Feature: Public register
  As waste holder
  I want to be able to find a registered waste carrier
  So that I can be sure that my waste is disposed of correctly

  For lower tier waste carriers their details should not be visible on the public
  register until they have confirmed their email account. Upper tier waste
  carriers should not be visible on the public register until their registration
  is paid for and approved.

Scenario: Lower tier waste carrier registers company, confirms email address and is visible on the public register
  Given I have registered as a lower tier charity waste carrier
  When I have confirmed my email address
  Then my lower tier charity waste registration details should be found on the public register

Scenario: Lower tier waste carrier registers company, unconfirmed email address and is not visible on the public register
  Given I have registered as a lower tier local authority waste carrier
  But I have not confirmed my email address details
  Then my lower tier local autority registration details should not be found on the public register

Scenario: Upper tier waste carrier registers company and confirms email is not visible on the public register when fee is not paid
  Given I have registered as an upper tier sole trader
  But I have not paid the registration charge
  When I have confirmed my email address
  Then my upper tier sole trader registration details should not be found on the public register

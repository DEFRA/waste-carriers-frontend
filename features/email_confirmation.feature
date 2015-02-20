Feature: Email confirmation

  As a waste carrier
  I want to be told to confirm my email address only when it's unconfirmed
  So that I get the added security this provides and aren't continually asked for it when it's no longer relevant
  
  Note: generally, we *cannot* use the data_creation steps here, because that skips sending the verification email.

  Scenario: lower tier unconfirmed
    Given I have gone through the lower tier waste carrier process
      But I have not confirmed my email address
     Then I am told to confirm my email address

  Scenario: After clicking the link in the 'verify your account' email, a Lower Tier carrier should be taken to the 'registration complete' page.
    Given I have gone through the lower tier waste carrier process
     When I activate my account by clicking the link in the activation email
     Then I am shown my confirmed registration
     
  Scenario: After clicking the link in the 'verify your account' email, an Upper Tier carrier should be taken to the 'email address confirmed' page.
    Given I have completed the upper tier and chosen to pay by bank transfer
     When I activate my account by clicking the link in the activation email
     Then I am shown the 'email address confirmed' page

  Scenario: upper tier unconfirmed
    Given I have completed the upper tier and chosen to pay by bank transfer
      And I am shown my pending registration
      But I have not confirmed my email address
     When I attempt to sign in
     Then I am told to confirm my email address

  Scenario: upper tier confirmed
    Given I have completed the upper tier and chosen to pay by bank transfer
      And I am shown my pending registration
      And I have received an awaiting payment email
     When I activate my account by clicking the link in the activation email
     Then I am shown the 'email address confirmed' page
     When I attempt to sign in
     Then I have applied as an upper tier waste carrier

  Scenario: upper tier unconfirmed with balance owing
    Given I have completed the upper tier and chosen to pay by bank transfer
      And I am shown my pending registration
     Then I am not shown how to pay in my confirmation email
  
  Scenario: When a user who has already confirmed their account requests that confirmation instructions are re-sent, they should get an email with the sign-in link.
    Given a "ST_LT_online_complete" lower tier registration
     Then searching the public register for 'company' should return 1 record
     When the inbox for 'st_lt@example.org' is emptied now as part of this test
      And I request that account confirmation instructions are re-sent for 'st_lt@example.org'
     Then the inbox for 'st_lt@example.org' should contain an email stating that the account is already confirmed

Feature: Email confirmation

  As a waste carrier
  I want to be told to confirm my email address only when it's unconfirmed
  So that I get the added security this provides and aren't continually asked for it when it's no longer relevant

  Scenario: lower tier unconfirmed
    Given I have gone through the lower tier waste carrier process
    When I have not confirmed my email address
    Then I am told to confirm my email address

  Scenario: lower tier confirmed
    Given I have gone through the lower tier waste carrier process
    When I have confirmed my email address
    Then I am shown my confirmed registration

  Scenario: upper tier unconfirmed
    Given I have completed the upper tier and chosen to pay by bank transfer
    When I have not confirmed my email address
    Then I am told to confirm my email address

  Scenario: upper tier confirmed
    Given I have completed the upper tier and chosen to pay by bank transfer
    When I have confirmed my email address
    Then I am shown my pending registration

  Scenario: upper tier unconfirmed with balance owing
    Given I have completed the upper tier and chosen to pay by bank transfer
    When I have not confirmed my email address
    Then I am shown how to pay in my confirmation email
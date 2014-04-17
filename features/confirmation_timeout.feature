Feature: confirmation link timeout

  As a waste carrier
  I want my account activation link to be live for a set amount of time
  So that the chances of someone else creating the account in my name is reduced

  Background:
    Given I have completed the lower tier registration form

  Scenario: Successful account activation within time limit
    When I activate the account within 12 hours
    Then my account is successfully activated

  Scenario: Unsuccessful account activation after time limit expired
    When I attempt to activate the account after 12 hours has elapsed
    Then I need to request a new confirmation email
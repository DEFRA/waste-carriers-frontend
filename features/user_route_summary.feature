Feature: user route summary dynamic panel
  As a waste carrier
  I want to be given a summary of my route and what waste carrying tier I am
  So that I can be confident I've filled out the form correctly

  Scenario: lower tier
    Given I have landed on the lower tier summary page
    Then I am told I am a lower tier waste carrier

  Scenario: upper tier
    Given I have landed on the upper tier summary page
    Then I am told I am an upper tier waste carrier
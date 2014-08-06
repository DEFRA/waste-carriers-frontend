Feature: Displaying convictions check to waste carriers

  Scenario: Declared convictions
    Given I fill out the upper tier steps
      And I declare convictions
      And I enter convictee details
    When I come to the confirmation step
    Then I see I declared convictions
      And I see a link to edit my conviction declaration
      And this takes me back to the conviction step

  Scenario: No declared convictions
    Given I fill out the upper tier steps
      And I do not declare convictions
    When I come to the confirmation step
    Then I see I did not declare convictions
      And I see a link to edit my conviction declaration
      And this takes me back to the conviction step

  Scenario: Did not declare convictions but our check says suspect
    Given I do not declare convictions
      But the convictions service says I am suspect
    When I come to the final step
    Then I am told my application is being checked
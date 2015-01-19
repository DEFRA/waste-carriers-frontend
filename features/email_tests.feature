Feature: Email tests

  Miscellaneous email-related tests that don't easily fit into the other features.

  Scenario: When a registration is revoked, the waste carrier should not receive an email
    Given a "ST_UT_online_complete" upper tier registration paid for by "Bank Transfer" with 0 copy cards
    And I wait for 2 seconds for these actions to be finalised
    And searching the public register for 'company' should return 1 record
    And the inbox for 'st_ut@example.org' is emptied now as part of this test
    And I am logged in as an NCCC agency user
    When I search for a registration using the text 'company'
    And I revoke the registration
    And I wait for 2 seconds for these actions to be finalised
    Then searching the public register for 'company' should return 0 records
    And the inbox for 'st_ut@example.org' should be empty

  # This test currently passes locally but not on the server. Quaranting till we understand why
  @quarantine
  Scenario: When a registration with a conviction check is approved, the waste carrier should receive a welcome email
    Given a pending "ST_UT_online_with_conviction" upper tier registration paid for by "Bank Transfer" with 0 copy cards
    And I wait for 2 seconds for these actions to be finalised
    And the inbox for 'st_ut@example.org' is emptied now as part of this test
    And I am logged in as an NCCC agency user
    When I search for a registration using the text 'company'
    And I approve the registration
    And I wait for 2 seconds for these actions to be finalised
    Then the inbox for 'st_ut@example.org' should contain an email with the subject 'Waste Carrier Registration Complete'
    When I search for a registration using the text 'company'
    Then the registration can no longer be approved

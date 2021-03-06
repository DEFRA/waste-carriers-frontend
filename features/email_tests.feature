Feature: Email tests

  Miscellaneous email-related tests that don't easily fit into the other features.

  Scenario: When a registration is revoked, the waste carrier should not receive an email
    Given a "ST_UT_online_complete" upper tier registration paid for by "Bank Transfer" with 0 copy cards
    And the inbox for 'st_ut@example.org' is emptied now as part of this test
    And I am logged in as an NCCC agency user
    When I search for and revoke the first registration that matches the text 'company'
    And I wait for 2 seconds for these actions to be finalised
    Then the inbox for 'st_ut@example.org' should be empty

  Scenario: When a registration with a conviction check is approved, the waste carrier should receive a welcome email
    Given a pending "ST_UT_online_with_conviction" upper tier registration paid for by "Bank Transfer" with 0 copy cards
    And the inbox for 'st_ut@example.org' is emptied now as part of this test
    And I am logged in as an NCCC agency user
    When I search for and approve the first registration that matches the text 'company'
    And I wait for 2 seconds for these actions to be finalised
    Then the inbox for 'st_ut@example.org' should contain an email with the subject 'Waste Carrier Registration Complete'
    And when I repeat the search for 'company', the registration can no longer be approved

Feature: Test data creation

Scenario: Create lower tier registrations

  Given a "Charity_LT_online_complete" lower tier registration
  And a "LTD_LT_online_complete" lower tier registration
  And a "PB_LT_online_complete" lower tier registration
  And a "PT_LT_online_complete" lower tier registration
  And a "ST_LT_online_complete" lower tier registration
  And a "WA_LT_online_complete" lower tier registration


Scenario: Create upper tier registrations

  Given a "LTD_UT_online_complete" upper tier registration paid for by "World Pay" with 12 copy cards
  And a "PB_UT_online_complete" upper tier registration paid for by "World Pay" with 0 copy cards
  And a "PT_UT_online_complete" upper tier registration paid for by "Bank Transfer" with 1 copy cards
  And a "ST_UT_online_complete" upper tier registration paid for by "Bank Transfer" with 0 copy cards

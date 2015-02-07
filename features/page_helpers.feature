Feature: Page Helpers

  As a newb with cucumber
  I want to test
  That my sort of page object stuff works

  Scenario: I complete the start page
    When I visit the start page
    And select the start page's "new" option
    Then I am shown the "type of business" page

  Scenario: I complete the business type page
    When I visit the start page
    And select the start page's "new" option
    And I select the business type page's "registration_businessType_soletrader" option
    Then I am shown the "other businesses" page

  Scenario: I complete the other businesses page
    When I visit the start page
    And select the start page's "new" option
    And I select the business type page's "registration_businessType_soletrader" option
    And I select the other businesses page's "registration_otherBusinesses_no" option
    Then I am shown the "construction" page

  Scenario: I complete the construction demolition page
    When I visit the start page
    And select the start page's "new" option
    And I select the business type page's "registration_businessType_soletrader" option
    And I select the other businesses page's "registration_otherBusinesses_no" option
    And I select the construction page's "registration_constructionWaste_yes" option
    Then I am shown the "carrier, broker and dealer" page

  Scenario: I complete the service provided page
    When I visit the start page
    And select the start page's "new" option
    And I select the business type page's "registration_businessType_soletrader" option
    And I select the other businesses page's "registration_otherBusinesses_yes" option
    And I select the service provided page's "registration_isMainService_yes" option
    Then I am shown the "animal" page

  Scenario: I complete the only deal with page
    When I visit the start page
    And select the start page's "new" option
    And I select the business type page's "registration_businessType_soletrader" option
    And I select the other businesses page's "registration_otherBusinesses_yes" option
    And I select the service provided page's "registration_isMainService_yes" option
    And I select the only deal with page's "registration_onlyAMF_no" option
    Then I am shown the "carrier, broker and dealer" page

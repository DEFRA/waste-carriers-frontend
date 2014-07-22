Feature: Discovery

  As a waste carrier
  I want to register in the applicable tier
  So that I'm compliant with regulations and only pay to register when I need to

  Workflow for the following scenarios can be found at:
  https://docs.google.com/spreadsheets/d/15SbDNrVbwh7nhQoEus-I5mv3RDIW_6nzwyxknUOuAXs/edit?usp=sharing

  Scenario Outline: Lower tier with own waste and no building waste
    Given I start a new registration
      And I enter my business type as <business_type>
      And I indicate I deal only with my own waste
      And I indicate I never deal with waste from building or demolition work
    Then I will be on the lower tier waste carrier registration path

    Examples:
      | business_type  |
      | soletrader     |
      | limitedcompany |
      | partnership    |
      | publicbody     |

  Scenario Outline: Upper tier with own waste and building waste
    Given I start a new registration
      And I enter my business type as <business_type>
      And I indicate I deal only with my own waste
      And I indicate I sometimes deal with waste from building or demolition work
    Then I will be on the upper tier waste carrier registration path

    Examples:
      | business_type  |
      | soletrader     |
      | limitedcompany |
      | partnership    |
      | publicbody     |

  Scenario Outline: Lower tier with other people's waste and main service and animal waste
    Given I start a new registration
      And I enter my business type as <business_type>
      And I indicate I deal with other people's waste too
      And I indicate disposing waste is my main service
      And I indicate I only deal with animal, farm, quarry or mine waste
    Then I will be on the lower tier waste carrier registration path

    Examples:
      | business_type  |
      | soletrader     |
      | limitedcompany |
      | partnership    |
      | publicbody     |

  Scenario Outline: Upper tier with other people's waste and main service and no animal waste
    Given I start a new registration
      And I enter my business type as <business_type>
      And I indicate I deal with other people's waste too
      And I indicate disposing waste is my main service
      And I indicate I don't deal with animal, farm, quarry or mine waste
    Then I will be on the upper tier waste carrier registration path

    Examples:
      | business_type  |
      | soletrader     |
      | limitedcompany |
      | partnership    |
      | publicbody     |

  Scenario Outline: Upper tier with other people's waste and no main service and building waste
    Given I start a new registration
      And I enter my business type as <business_type>
      And I indicate I deal with other people's waste too
      And I indicate disposing waste is not my main service
      And I indicate I sometimes deal with waste from building or demolition work
    Then I will be on the upper tier waste carrier registration path

    Examples:
      | business_type  |
      | soletrader     |
      | limitedcompany |
      | partnership    |
      | publicbody     |

  Scenario Outline: Lower tier with other people's waste and no main service and no building waste
    Given I start a new registration
      And I enter my business type as <business_type>
      And I indicate I deal with other people's waste too
      And I indicate disposing waste is not my main service
      And I indicate I never deal with waste from building or demolition work
    Then I will be on the lower tier waste carrier registration path

    Examples:
      | business_type  |
      | soletrader     |
      | limitedcompany |
      | partnership    |
      | publicbody     |

  Scenario Outline: Definite lower tier determined just by business type
    Given I start a new registration
      And I enter my business type as <business_type>
    Then I will be on the lower tier waste carrier registration path

    Examples:
      | business_type |
      | charity       |
      | authority     |

  Scenario: First wizard page
    Given I start a new registration
    Then there is no back button on the page
      But there is a next button on the page

  Scenario: Some other business type
    Given I start a new registration
      And I enter my business type as other
    Then I am told to ring the Environment Agency

  Scenario: Going back when there's many routes back (via other businesses step)
    Given I navigate to the construction/demolition step via the other businesses step
    When I click the back link
    Then I end up on the other businesses step

  Scenario: Going back when there's many routes back (via main service step)
    Given I navigate to the construction/demolition step via the main service step
    When I click the back link
    Then I end up on the main service step

  Scenario: Following the breadcrumb as opposed to going to the strictly previous step
    Given I navigate to the construction/demolition step via the other businesses step
    When I click the back link twice
    Then I follow the breadcrumb trail
      And I end up on the business type step
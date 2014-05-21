Feature: Discovery

  As a waste-carrier
  I want to register in the applicable tier
  So that I'm compliant with regulations and only pay to register when I need to

  Workflow for the following scenarios can be found at:
  https://docs.google.com/spreadsheets/d/15SbDNrVbwh7nhQoEus-I5mv3RDIW_6nzwyxknUOuAXs/edit?usp=sharing

  @happy_day
  Scenario Outline: Own waste and no building waste
    Given I am on the discovery page
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

  @happy_day
  Scenario Outline: Own waste and building waste
    Given I am on the discovery page
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

  @happy_day
  Scenario Outline: Other waste and main service and animal waste
    Given I am on the discovery page
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

  @happy_day
  Scenario Outline: Other waste and main service and no animal waste
    Given I am on the discovery page
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

  @happy_day
  Scenario Outline: Other waste and no main service and building waste
    Given I am on the discovery page
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

  @happy_day
  Scenario Outline: Other waste and no main service and no building waste
  Given I am on the discovery page
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

  @happy_day
  Scenario Outline: Charities and authorities
  Given I am on the discovery page
    And I enter my business type as <business_type>
  Then I will be on the lower tier waste carrier registration path

    Examples:
      | business_type |
      | charity       |
      | authority     |

  Scenario: First wizard page
    Given I am on the discovery page
    Then there is no back button on the page

  @happy_day
  Scenario: Others
    Given I am on the discovery page
      And I enter my status as 'Other'
    Then the system tells me I must contact EA by phone

  Scenario: Back link
    Given I am on the discovery page
      And I enter my status as 'sole_trader'
      And I indicate I deal with other waste too
      And I indicate disposing waste is my main service
      And I indicate I don't deal with animal, farm, quarry or mine waste
      And I click on the 'Back Link' twice
    Then I see the screen where I told the system I deal with other waste too
      And my original choice is still there

  Scenario: Back button
    Given I am on the discovery page
      And I enter my status as 'sole_trader'
      And I indicate I deal with other waste too
      And I indicate disposing waste is my main service
      And I indicate I don't deal with animal, farm, quarry or mine waste
      And I click on the 'Back Button' twice
    Then I see the screen where I told the system I deal with other waste too
      And my original choice is still there





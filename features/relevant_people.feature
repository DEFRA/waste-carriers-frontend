Feature: Relevant People

  As a waste carrier
  I want to record all relevant people for my organisation
  So that I'm compliant with regulations and my registration is valid


  Scenario: Completing a sole trader registration - no relevant people added
    Given I am registering as a sole trader
    And I am a carrier dealer
    And I provide my company name
    And I autocomplete my business address
    And I provide my personal contact details
    And I provide a postal address
    And I Enter my details
    And There are relevant people with relevant convictions in my organisation
    Then I cannot proceed until I have added a relevant person


  Scenario: Completing a sole trader registration with multiple relevant people
    Given I am registering as a sole trader
    And I am a carrier dealer
    And I provide my company name
    And I autocomplete my business address
    And I provide my personal contact details
    And I provide a postal address
    And I Enter my details
    And There are relevant people with relevant convictions in my organisation
    And I enter the following people with relevant convictions:
        | first_name | last_name | position | dob_day | dob_month | dob_year |
        | James      | Hunt      | Driver   | 29      | 08        | 1947     |
        | Nikki      | Lauda     | Driver   | 22      | 02        | 1949     |
     Then I should see the following names listed:
        | first_name | last_name |
        | James      | Hunt      |
        | Nikki      | Lauda     |


 Scenario: Editing relevant people details for sole trader registration with multiple relevant people
    Given I am registering as a sole trader
    And I am a carrier dealer
    And I provide my company name
    And I autocomplete my business address
    And I provide my personal contact details
    And I provide a postal address
    And I Enter my details
    And There are relevant people with relevant convictions in my organisation
    And I enter the following people with relevant convictions:
        | first_name | last_name | position | dob_day | dob_month | dob_year |
        | James      | Hunt      | Driver   | 29      | 08        | 1947     |
        | Nikki      | Lauda     | Driver   | 22      | 02        | 1949     |
    And I finish my convictions declaration
    When I choose to edit the conviction declaration
    Then I should see the following names listed:
        | first_name | last_name |
        | James      | Hunt      |
        | Nikki      | Lauda     |


  Scenario: Completing a Partnership registration - no relevant people added
    Given I am registering as a Partnership
    And I am a carrier dealer
    And I provide my company name
    And I autocomplete my business address
    And I provide my personal contact details
    And I provide a postal address
    And I Enter my details for two partners
    And There are relevant people with relevant convictions in my organisation
    Then I cannot proceed until I have added a relevant person


  Scenario: Completing a Partnership registration with multiple relevant people
    Given I am registering as a Partnership
    And I am a carrier dealer
    And I provide my company name
    And I autocomplete my business address
    And I provide my personal contact details
    And I provide a postal address
    And I Enter my details for two partners
    And There are relevant people with relevant convictions in my organisation
    And I enter the following people with relevant convictions:
        | first_name | last_name | position | dob_day | dob_month | dob_year |
        | James      | Hunt      | Driver   | 29      | 08        | 1947     |
        | Nikki      | Lauda     | Driver   | 22      | 02        | 1949     |
     Then I should see the following names listed:
        | first_name | last_name |
        | James      | Hunt      |
        | Nikki      | Lauda     |


  Scenario: Editing relevant person details for Partnership registration with multiple relevant people
    Given I am registering as a Partnership
    And I am a broker dealer
    And I provide my company name
    And I autocomplete my business address
    And I provide my personal contact details
    And I provide a postal address
    And I Enter my details for two partners
    And There are relevant people with relevant convictions in my organisation
    And I enter the following people with relevant convictions:
        | first_name | last_name | position | dob_day | dob_month | dob_year |
        | James      | Hunt      | Driver   | 29      | 08        | 1947     |
        | Nikki      | Lauda     | Driver   | 22      | 02        | 1949     |
    And I finish my convictions declaration
    When I choose to edit the conviction declaration
    Then I should see the following names listed:
        | first_name | last_name |
        | James      | Hunt      |
        | Nikki      | Lauda     |

 Scenario: Editing sole trader details with multiple relevant people
    Given I am registering as a sole trader
    And I am a carrier dealer
    And I provide my company name
    And I autocomplete my business address
    And I provide my personal contact details
    And I provide a postal address
    And I Enter my details
    And There are relevant people with relevant convictions in my organisation
    And I enter the following people with relevant convictions:
        | first_name | last_name | position | dob_day | dob_month | dob_year |
        | James      | Hunt      | Driver   | 29      | 08        | 1947     |
        | Nikki      | Lauda     | Driver   | 22      | 02        | 1949     |
    And I finish my convictions declaration
    When I edit my sole trader business owner details
    And There are relevant people with relevant convictions in my organisation
    Then I should see the following names listed:
        | first_name | last_name |
        | James      | Hunt      |
        | Nikki      | Lauda     |

Scenario: Editing Partnership details with multiple relevant people - add partner
    Given I am registering as a Partnership
    And I am a carrier dealer
    And I provide my company name
    And I autocomplete my business address
    And I provide my personal contact details
    And I provide a postal address
    And I Enter my details for two partners
    And There are relevant people with relevant convictions in my organisation
    And I enter the following people with relevant convictions:
        | first_name | last_name | position | dob_day | dob_month | dob_year |
        | James      | Hunt      | Driver   | 29      | 08        | 1947     |
        | Nikki      | Lauda     | Driver   | 22      | 02        | 1949     |
    And I finish my convictions declaration
    When I edit my business owner details
    And add another Partner
    And There are relevant people with relevant convictions in my organisation
    Then I should see the following names listed:
        | first_name | last_name |
        | James      | Hunt      |
        | Nikki      | Lauda     |

Scenario: Editing Partnership details with multiple relevant people - change partner
    Given I am registering as a Partnership
    And I am a carrier dealer
    And I provide my company name
    And I autocomplete my business address
    And I provide my personal contact details
    And I provide a postal address
    And I Enter my details for two partners
    And There are relevant people with relevant convictions in my organisation
    And I enter the following people with relevant convictions:
        | first_name | last_name | position | dob_day | dob_month | dob_year |
        | James      | Hunt      | Driver   | 29      | 08        | 1947     |
        | Nikki      | Lauda     | Driver   | 22      | 02        | 1949     |
    And I finish my convictions declaration
    When I edit my business owner details
    And change another Partner
    And There are relevant people with relevant convictions in my organisation
    Then I should see the following names listed:
        | first_name | last_name |
        | James      | Hunt      |
        | Nikki      | Lauda     |

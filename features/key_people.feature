Feature: Key People

  As a waste carrier
  I want to record all key people for my organisation
  So that I'm compliant with regulations and my registration is valid

  Scenario: Sole Trader
    Given I have been funneled into the upper tier path
      And I am a carrier dealer
      And I provide my company name
    Given I autocomplete my business address
      And I provide my personal contact details
     Then I should only have to enter one key person

  Scenario: Partnership
    Given I am a partnership on the upper tier path
      And I am a carrier dealer
      And I provide my company name
    Given I autocomplete my business address
      And I provide my personal contact details
     Then I cannot proceed until I have added a key person

  Scenario: Partnership with multiple partners
    Given I am a partnership on the upper tier path
      And I am a carrier dealer
      And I provide my company name
    Given I autocomplete my business address
      And I provide my personal contact details
      And I add the following key people:
        | first_name | last_name | dob_day | dob_month | dob_year |
        | James      | Hunt      | 29      | 08        | 1947     |
        | Nikki      | Lauda     | 22      | 02        | 1949     |
     Then I should see the following names listed:
        | first_name | last_name |
        | James      | Hunt      |
        | Nikki      | Lauda     |


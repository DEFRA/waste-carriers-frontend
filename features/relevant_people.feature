Feature: Relevant People

  As a waste carrier
  I want to record all relevant people for my organisation
  So that I'm compliant with regulations and my registration is valid

  Scenario: Completing a valid registration
    Given I am registering as an upper tier waste carrier
      And There are relevant people with relevant convictions in my organisation
     Then I cannot proceed until I have added a relevant person

  Scenario: Completing a valid registration with multiple relevant people
    Given I am registering as an upper tier waste carrier
      And There are relevant people with relevant convictions in my organisation
      And I enter the following people with relevant convictions:
        | first_name | last_name | position | dob_day | dob_month | dob_year |
        | James      | Hunt      | Driver   | 29      | 08        | 1947     |
        | Nikki      | Lauda     | Driver   | 22      | 02        | 1949     |
     Then I should see the following names listed:
        | first_name | last_name |
        | James      | Hunt      |
        | Nikki      | Lauda     |

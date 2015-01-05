Feature: Upper tier

  As an upper tier waste carrier
  I want to complete the upper tier form
  So that my registration is processed with the Environment Agency

Background:
  Given I have been funneled into the upper tier path
  And I am a carrier dealer
  And I provide my company name

Scenario: Autocomplete address
  Given I autocomplete my business address
  And I provide my personal contact details
  And I enter the details of the business owner
  And no key people in the organisation have convictions
  And I check the declaration
  And I provide my email address and create a password
  And I choose pay via electronic transfer
  Then I have completed the application as an upper tier waste carrier via electronic transfer

Scenario: Autocomplete with unrecognised postcode
  Given I want my business address autocompleted but I provide an unrecognised postcode
  When I try to select an address
  Then no address suggestions will be shown
  But I can edit this postcode
  And add my address manually if I wanted to

Scenario: Manually enter UK address
  Given I enter my business address manually
  And I provide my personal contact details
  And I enter the details of the business owner
  And no key people in the organisation have convictions
  And I check the declaration
  And I provide my email address and create a password
  And I choose pay via electronic transfer
  Then I have completed the application as an upper tier waste carrier via electronic transfer

Scenario: Foreign waste carrier
  Given I enter my foreign business address manually
  And I provide my personal contact details
  And I enter the details of the business owner
  And no key people in the organisation have convictions
  And I check the declaration
  And I provide my email address and create a password
  And I choose pay via electronic transfer
  Then I have completed the application as an upper tier waste carrier via electronic transfer

@javascript @quarantine @worldpay
Scenario: Card payment
  Given I autocomplete my business address
  And I provide my personal contact details
  And I enter the details of the business owner
  And no key people in the organisation have convictions
  And I check the declaration
  And I provide my email address and create a password
  And I pay by card
  And I am registered as an upper tier waste carrier
  When I re-request activation for my account
  Then I am shown the sign in page
  And I attempt to sign in
  Then I am successfully registered and activated as an upper tier waste carrier

Scenario: Bank transfer
  Given I autocomplete my business address
  And I provide my personal contact details
  And I enter the details of the business owner
  And no key people in the organisation have convictions
  And I check the declaration
  And I provide my email address and create a password
  And I choose to pay by bank transfer
  And I make a note of the details
  Then my upper tier waste carrier registration is pending until payment is received by the Environment Agency

Scenario: With convictions
  Given I autocomplete my business address
  And I provide my personal contact details
  And I enter the details of the business owner
  And key people in the organisation have convictions
  And I enter the following people with relevant convictions:
    | first_name | last_name | position | dob_day | dob_month | dob_year |
    | James      | Hunt      | Driver   | 29      | 08        | 1947     |
    | Nikki      | Lauda     | Driver   | 22      | 02        | 1949     |
  And I click next
  And I check the declaration
  And I provide my email address and create a password
  And I choose pay via electronic transfer
  Then I am told my registration is pending a convictions check

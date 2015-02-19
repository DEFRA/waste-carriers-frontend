@wip
Feature: external renewals

  As a waste carrier
  I want to be able to renew my registration
  So that I can continue to be registered as a waste carrier

# TODO marked as @wip as tests cannot be completed until renewal code fixed (using renewal link on certificates page)

# This background task creates a registration for which the scenarios can perform renew related tests
Background:
  Given I have been funneled into the upper tier path
  And I am a carrier dealer
  And I provide the following company name: RenewalTest
  And I autocomplete my business address
  And I provide my personal contact details
  And I enter the details of the business owner
  And no key people in the organisation have convictions
  And I check the declaration
  And I provide my email address and create a password
  And I pay by card
  Then registration should be complete
  And I remember the registration id
  And I am registered as an upper tier waste carrier
  When I activate my account by clicking the link in the activation email
  And I am in the Expiry period
  And I attempt to sign in
  Then I am successfully registered and activated as an upper tier waste carrier

@wip @javascript
Scenario: Upper tier Renewal, No changes, Online payment
  Given The renewal link is available
  Then I click the renew link for: RenewalTest
  And I check the declaration
  And I pay by card
  Then my renewal should be complete
  And the expiry date should be updated

@wip @javascript
Scenario: Upper tier Renewal, No changes, Offline payment
  Given The renewal link is available
  Then I click the renew link for: RenewalTest
  And I check the declaration
  And I choose pay via electronic transfer
  Then my renewal should be awaiting payment
  # This is a silly test as the expiry date wont be updated till the after payment is received but it validates the date
  And the expiry date should be updated

@wip @javascript
Scenario: Upper tier Renewal that forces a New Registration, Online payment
  Given The renewal link is available
  Then I click the renew link for: RenewalTest
  And I change the legal entity
  And I check the declaration
  And I pay by card
  Then my renewal should be complete
  And the expiry date should be updated

@wip @javascript
Scenario: Upper tier Renewal that forces a New Registration, Offline payment
  Given The renewal link is available
  Then I click the renew link for: RenewalTest
  And I change the legal entity
  And I check the declaration
  And I choose pay via electronic transfer
  Then my renewal should be awaiting payment
  # This is a silly test as the expiry date wont be updated till the after payment is received but it validates the date
  And the expiry date should be updated

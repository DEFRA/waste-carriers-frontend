Given(/^The renewal link is available$/) do
  # This will only be true given the current set of expiration parameters, ie any new registration created is automatically able to be expired
  page.has_text? 'Renew registration'
end

Then(/^I click the renew link for: (.*)$/) do |name|
  # FIXME: Improve this test to find a unique renew link
  # Uses the saved registration ID to find the correct registration to renew
  click_link 'renew_'+@stored_value
end

Then(/^my renewal should be complete$/) do
  page.has_text? 'Registration complete'
  click_button 'finished'
  page.has_text? 'ACTIVE'
end

Then(/^my renewal should be awaiting payment$/) do
  page.has_text? 'Almost there'
  page.has_text? 'Your certificate and guidance have been emailed to'
  click_button 'finished'
  # This is not a great test as it checks if the previous registration is still active not if the new one has been extended
  # That test is covered by the step 'the expiry date should be updated'
  page.has_text? 'ACTIVE'
end

Then(/^the expiry date should be updated$/) do
  # Get expiry period from configuration and check page has expected expiry date
  d = Date.today + Rails.configuration.registration_expires_after
  page.has_text? d.strftime("%d-%^B-%Y")
end

Given(/^I provide the following company name: (.*)$/) do |table|
  # table is a Cucumber::Ast::Table
  fill_in 'registration_companyName', with: table
end

Then(/^I remember the registration id$/) do
  # Find the registration ID and saves it as a variable for use in a later test
  @stored_value = find_by_id('registrationNumber').text.to_s
end

And(/^I am in the Expiry period$/) do
  # Expiry date - 1 day
  Timecop.travel(Time.now + Rails.configuration.registration_expires_after - 1.day)
end
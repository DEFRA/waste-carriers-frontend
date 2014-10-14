Given(/^The renewal link is available$/) do
  # This will only be true given the current set of expiration parameters, ie any new registration created is automatically able to be expired
  page.should have_content 'Renew Registration'
end

Then(/^I click the renew link for: (.*)$/) do |name|
  # FIXME: Improve this test to find a unique renew link
  puts 'Searching reg for: ' + name.to_s
  # Uses the saved registration ID to find the correct registration to renew
  puts 'Using @stored_value: ' + @stored_value
  click_on 'renew_'+@stored_value
end

Then(/^my renewal should be complete$/) do
  page.should have_content 'Your changes have been successful'
  page.should have_content 'Your certificate and guidance have been emailed to'
  click_on 'Finish'
  page.should have_content 'ACTIVE'
end

Then(/^my renewal should be awaiting payment$/) do
  page.should have_content 'Almost there'
  page.should have_content 'Your certificate and guidance have been emailed to'
  click_on 'Finish'
  # This is not a great test as it checks if the previous registration is still active not if the new one has been extended
  # That test is covered by the step 'the expiry date should be updated'
  page.should have_content 'ACTIVE'
end

Then(/^the expiry date should be updated$/) do
  # Get expiry period from configuration and check page has expected expiry date
  d = Date.today + Rails.configuration.registration_expires_after
  page.should have_content d.strftime("%d-%^B-%Y")
end

Given(/^I provide the following company name: (.*)$/) do |table|
  # table is a Cucumber::Ast::Table
  puts 'Creating reg for: ' + table.to_s
  fill_in 'registration_companyName', with: table
end

Then(/^I remember the registration id$/) do
  # Find the registration ID and saves it as a variable for use in a later test
  @stored_value = find_by_id('registrationNumber').text.to_s
  puts 'Saves @stored_value: ' + @stored_value
end

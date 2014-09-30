Given(/^The renewal link is available$/) do
  # This will only be true given the current set of expiration parameters, ie any new registration created is automatically able to be expired
  page.should have_content 'Renew Registration'
end

Then(/^I click the renew link$/) do
  click_on 'Renew Registration'
end

Then(/^my renewal should be complete$/) do
  # This is currently registration complete as that is how it works but ideally renewals should state renewal complete
  page.should have_content 'Registration complete'
  click_on 'Finish'
  page.should have_content 'ACTIVE'
end

Then(/^the expiry date should be updated$/) do
  # Get expiry period from configuration and check page has expected expiry date
  d = Date.today + Rails.configuration.registration_expires_after
  page.should have_content d.strftime("%d-%^B-%Y")
end

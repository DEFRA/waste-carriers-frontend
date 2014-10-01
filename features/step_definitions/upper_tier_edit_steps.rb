Given(/^The edit link is available$/) do
  page.should have_content 'Edit Registration'
  page.should have_link('edit_'+@stored_value)
end

Then(/^I click the edit link for: (.*)$/) do |name|
  # Uses the saved registration ID to find the correct registration to renew
  puts 'Using registration id: ' + @stored_value
  click_on 'edit_'+@stored_value
end

Then(/^I check that no changes have occurred$/) do
  page.should have_content 'Your registrations'
  page.should have_content 'Edit Registration'
end

Then(/^I change the way we carry waste$/) do
  page.should have_link('changeRegistrationType')
  click_on 'changeRegistrationType'
  # Change type to different registration type assuming this is different from original
  choose 'registration_registrationType_carrier_broker_dealer'
  click_on 'Next'
end

Then(/^I am asked to pay for the changes$/) do  
  page.should have_content 'Payment summary'
  # Verify the edit change fee of 40
  find_by_id('registration_registration_fee').value.should == '40.00'
end

Then(/^my edit should be complete$/) do
  # This is currently registration complete as that is how it works but ideally renewals should state edit complete
  page.should have_content 'Registration complete'
  # Update this once more appropriate content has been created
  page.should have_content 'TBC - Edit / Renew order complete page'
  click_on 'Finish'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'
  page.should have_content 'Edit Registration'
end

Then(/^my edit should be awaiting payment$/) do
  # This is currently registration complete as that is how it works but ideally renewals should state edit complete
  page.should have_content 'Almost there'
  # Update this once more appropriate content has been created
  page.should have_content 'Edited: with charge'
  click_on 'Finish'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'
  page.should have_content 'Edit Registration'
end

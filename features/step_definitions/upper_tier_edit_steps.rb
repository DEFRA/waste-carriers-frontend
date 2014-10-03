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

Then(/^I change the legal entity$/) do
  page.should have_link('changeSmartAnswers')
  click_on 'changeSmartAnswers'

  # The following pages are shown if Partner now selected
  choose 'registration_businessType_partnership'
  click_on 'Next'
  
  #
  #
  # VERIFY that these options are preselected and thus dont re-choose them
  #
  #
  choose 'registration_otherBusinesses_yes'
  click_on 'Next'
  
  choose 'registration_isMainService_no'
  click_on 'Next'
  
  choose 'registration_constructionWaste_yes'
  click_on 'Next'
  
  # Now on Parter details page
  
  # TODO: Fill in partners details
  fill_in 'key_person_first_name', with: 'Steve'
  fill_in 'key_person_last_name', with: 'Rogers'
  fill_in 'key_person_dob_day', with: '3'
  fill_in 'key_person_dob_month', with: '10'
  fill_in 'key_person_dob_year', with: '1964'
  
  click_on 'Next'
  
  # Then on declared convictions page
  #choose 'registration_declaredConvictions_no'
  click_on 'Next'  
end

Then(/^I am asked to pay for the edits$/) do  
  page.should have_content 'Payment summary'
  # Verify the edit change fee of 40
  Money.new(Rails.configuration.fee_reg_type_change)
  find_by_id('registration_registration_fee').value.should == '40.00'
end

Then(/^I am asked to pay for the edits expecting a full fee$/) do  
  page.should have_content 'Payment summary'
  # Verify the edit change fee of 154
  find_by_id('registration_registration_fee').value.should == Money.new(Rails.configuration.fee_registration).to_s
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

Then(/^my edit with full fee should be complete$/) do
  # This is currently registration complete as that is how it works but ideally renewals should state edit complete
  page.should have_content 'Registration complete'
  # Update this once more appropriate content has been created
  page.should have_content 'Edited registration'
  page.should have_content 'Edited: new registration'
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

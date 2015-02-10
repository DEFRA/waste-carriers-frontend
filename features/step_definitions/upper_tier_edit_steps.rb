Given(/^The edit link is available$/) do
  page.should have_content 'Edit Registration'
  page.should have_link('edit_'+@stored_value)
end

Then(/^I click the edit link for: (.*)$/) do |name|
  # Uses the saved registration ID to find the correct registration to renew
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
  click_button 'continue'
end

Then(/^I change the legal entity$/) do
  page.should have_link('changeSmartAnswers')
  click_on 'changeSmartAnswers'

  # The following pages are shown if Partner now selected
  choose 'registration_businessType_partnership'
  click_button 'continue'

  #
  #
  # VERIFY that these options are preselected and thus dont re-choose them
  #
  #
  #choose 'registration_otherBusinesses_yes'
  click_button 'continue'

  #choose 'registration_isMainService_no'
  click_button 'continue'

  #choose 'registration_constructionWaste_yes'
  click_button 'continue'

  # Now on registration type
  click_button 'continue'

  #
  # Alternatives to try to select the second value in the drop down list
  #
  #find_by_id('registration_selectedAddress').find(:xpath, 'option[2]').select_option
  #select find_by_id('registration_selectedAddress').find(:xpath, 'option[2]')
  #within 'registration_selectedAddress' do
  #  find("option[1]").click
  #end
  #page.find_by_id('registration_selectedAddress').find("option[1]").select_option
  #page.find_and_select_option("registration_selectedAddress", 2)

  #
  # TEMP FIX: This fixes an issue in the tests and in Safari which render this page with an unselected address
  # This line forceably selects the first useable address
  #
  select(find_by_id('registration_selectedAddress').find(:xpath, 'option[2]').text.to_s, :from => 'registration_selectedAddress')

  # Now on business details
  click_button 'continue'

  # Now on contact type
  click_button 'continue'

  # Now on Parter details page

  # TODO: Fill in partners details
  fill_in 'key_person_first_name', with: 'Steve'
  fill_in 'key_person_last_name', with: 'Rogers'
  fill_in 'key_person_dob_day', with: '3'
  fill_in 'key_person_dob_month', with: '10'
  fill_in 'key_person_dob_year', with: '1964'

  click_button 'continue'

  # Then on declared convictions page
  #choose 'registration_declaredConvictions_no'
  click_button 'continue'
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
  page.should have_content 'Your changes have been successful'
  # Update this once more appropriate content has been created
  page.should have_content 'Your certificate and guidance have been emailed to'
  click_on 'Finish'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'
  page.should have_content 'Edit Registration'
end

Then(/^my edit should be awaiting payment$/) do
  # This is currently registration complete as that is how it works but ideally renewals should state edit complete
  page.should have_content 'Almost there'
  # Update this once more appropriate content has been created
  page.should have_content 'Your certificate and guidance have been emailed to'
  click_on 'Finish'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'
  page.should have_content 'Edit Registration'
end

Then(/^my edit with full fee should be complete$/) do
  # This is currently registration complete as that is how it works but ideally renewals should state edit complete
  page.should have_content 'Registration complete'
  # Update this once more appropriate content has been created
  page.should have_content 'Registration complete'
  page.should have_content 'Your registration number is'
  click_on 'Finish'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'
  page.should have_content 'Edit Registration'
end

Then(/^my edit with full fee should be awaiting payment$/) do
  # This is currently registration complete as that is how it works but ideally renewals should state edit complete
  page.should have_content 'Almost there'
  # Update this once more appropriate content has been created
  page.should have_content 'Your registration number is'
  page.should have_content 'Please remember to arrange your bank transfer'
  click_on 'Finish'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'
  page.should have_content 'PENDING'
end

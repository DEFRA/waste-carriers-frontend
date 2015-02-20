Given(/^The edit link is available$/) do
  page.has_text? 'Edit Registration'
  page.has_link? "edit_#{@cucumber_reg_id}"
end

Then(/^I click the Edit Registration link$/) do
  # Uses the saved registration ID to find the correct registration to renew
  click_link "edit_#{@cucumber_reg_id}"
end

Then(/^I check that no changes have occurred$/) do
  page.has_text? 'Your registrations'
  page.has_text? 'Edit Registration'
end

Then(/^I change the way we carry waste$/) do
  page.has_link? 'changeRegistrationType'
  click_link 'changeRegistrationType'
  # Change type to different registration type assuming this is different from original
  choose 'registration_registrationType_carrier_broker_dealer'
  click_button 'continue'
end

Then(/^I change the legal entity$/) do
  page.has_link? 'changeSmartAnswers'
  click_link 'changeSmartAnswers'

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
  page.has_text? 'Payment summary'
  # Verify the edit change fee of 40
  Money.new(Rails.configuration.fee_reg_type_change)
  find_by_id('registration_registration_fee').value.should == '40.00'
end

Then(/^I am asked to pay for the edits expecting a full fee$/) do
  page.has_text? 'Payment summary'
  # Verify the edit change fee of 154
  find_by_id('registration_registration_fee').value.should == Money.new(Rails.configuration.fee_registration).to_s
end

Then(/^my edit should be complete$/) do
  page.find_by_id "ut_complete_or_lower_tier"
  click_button 'finished_btn'
  # Check routing after clicking finished
  page.find_by_id "edit_#{@cucumber_reg_id}"
end

Then(/^my edit should be awaiting payment$/) do
  page.find_by_id "ut_bank_transfer"
  click_button 'finished_btn'
  # Check routing after clicking finished
  page.find_by_id "edit_#{@cucumber_reg_id}"
end

Then(/^my edit with full fee should be complete$/) do
  page.has_text? 'Registration complete'
  @new_reg_id = find_by_id('registrationNumber').text.to_s
  click_button 'finished_btn'
  # Check routing after clicking finish
  page.find_by_id "edit_#{@new_reg_id}"
  page.has_text? 'ACTIVE'
end

Then(/^my edit with full fee should be awaiting payment$/) do
  page.has_text? 'Application received'
  @new_reg_id = find_by_id('registrationNumber').text.to_s
  click_button 'finished_btn'
  # Check routing after clicking finish
  page.has_text? "#{@new_reg_id}"
  page.has_text? 'PENDING'
end

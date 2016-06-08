Given(/^The edit link is available$/) do
  expect(page).to have_text 'Edit registration'
  expect(page).to have_link "edit_#{@cucumber_reg_id}"
end

Then(/^I click the Edit Registration link$/) do
  # Uses the saved registration ID to find the correct registration to renew
  click_link "edit_#{@cucumber_reg_id}"
end

Then(/^Edit The Registration$/) do
  # Uses the saved registration ID to find the correct registration to renew
  click_link "Edit registration"
end

Then(/^I visit the edit registration page$/) do
  visit edit_registration_path(@raw_id)
end

Then(/^I check that no changes have occurred$/) do
  expect(page).to have_text 'Your waste carrier registrations'
  expect(page).to have_text 'Edit registration'
end

Then(/^I change the way we carry waste$/) do
  expect(page).to have_link 'changeRegistrationType'
  click_link 'changeRegistrationType'
  # Change type to different registration type assuming this is different from
  # original
  choose 'registration_registrationType_carrier_broker_dealer'
  click_button 'continue'
end

Then(/^I click Edit what you told us$/) do
  expect(page).to have_link 'changeSmartAnswers'
  click_link 'changeSmartAnswers'
end

Then(/^I change the legal entity$/) do
  expect(page).to have_link 'changeSmartAnswers'
  click_link 'changeSmartAnswers'

  # Business type
  # The following pages are shown if Partner now selected
  choose 'registration_businessType_partnership'
  click_button 'continue'

  # Waste from other businesses
  # TODO: Verify that this option is preselected and thus dont re-choose it
  # choose 'registration_otherBusinesses_yes'
  click_button 'continue'

  # Construction or demolition
  # TODO: Verify that this option is preselected and thus dont re-choose it
  # choose 'registration_constructionWaste_yes'
  click_button 'continue'

  # Registration type
  # TODO: Verify that this option is preselected and thus dont re-choose it
  # choose 'registration_registrationType_carrier_dealer'
  click_button 'continue'

  # Business details
  # TODO: Verify that fields are already filled in with correct details
  click_button 'continue'

  # Contact details
  click_button 'continue'

  # Postal address
  click_button 'continue'

  # Key people - Partner details page
  fill_in 'key_person_first_name', with: 'Steve'
  fill_in 'key_person_last_name', with: 'Rogers'
  fill_in 'key_person_dob_day', with: '3'
  fill_in 'key_person_dob_month', with: '10'
  fill_in 'key_person_dob_year', with: '1964'
  click_button 'continue'

  # Relevant convictions
  click_button 'continue'
end

Then(/^I am asked to pay for the edits$/) do
  expect(page).to have_text 'Payment summary'
  # Verify the edit change fee of 40
  Money.new(Rails.configuration.fee_reg_type_change)
  expect(find_by_id('registration_registration_fee').value).to have_text '40.00'
end

Then(/^I am asked to pay for the edits expecting a full fee$/) do
  expect(page).to have_text 'Payment summary'
  # Verify the edit change fee of 154
  expect(find_by_id('registration_registration_fee').value).to have_text Money.new(Rails.configuration.fee_registration).to_s
end

Then(/^my edit should be complete$/) do
  expect(page).to have_selector(:id, 'ut_complete_or_lower_tier')
  click_button 'finished_btn'
  # Check routing after clicking finished
  expect(page).to have_selector(:id, "edit_#{@cucumber_reg_id}")
end

Then(/^my edit should be awaiting payment$/) do
  expect(page).to have_selector(:id, 'ut_bank_transfer')
  click_button 'finished_btn'
  # Check routing after clicking finished
  expect(page).to have_selector(:id, "edit_#{@cucumber_reg_id}")
end

Then(/^my edit with full fee should be complete$/) do
  expect(page).to have_text 'Registration complete'
  @new_reg_id = find_by_id('registrationNumber').text.to_s
  click_button 'finished_btn'
  # Check routing after clicking finish
  expect(page).to have_selector(:id, "edit_#{@new_reg_id}")
  expect(page).to have_text 'ACTIVE'
end

Then(/^my edit with full fee should be awaiting payment$/) do
  expect(page).to have_text 'Application received'
  @new_reg_id = find_by_id('registrationNumber').text.to_s
  click_button 'finished_btn'
  # Check routing after clicking finish
  expect(page).to have_text "#{@new_reg_id}"
  expect(page).to have_text 'PENDING'
end

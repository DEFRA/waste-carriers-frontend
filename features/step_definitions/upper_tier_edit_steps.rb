Then(/^I visit the edit registration page$/) do
  visit edit_registration_path(@raw_id)
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

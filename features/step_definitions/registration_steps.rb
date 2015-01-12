Then(/^I should see the Finish page$/) do
  page.should have_content 'The registration number is'
  page.should have_button 'finished_btn'
end

When(/^I search for a registration using the text '([\w ]+)'$/) do |search_text|
  fill_in 'q', with: search_text    # 'q' is the 'Search for' field.
  click_button 'reg-search'
end

When(/^I revoke the registration$/) do
  # This step assumes that only one registration is currently shown in the search results.
  click_link 'Revoke'
  fill_in 'registration_metaData_revokedReason', with: 'revoked by cucumber test'
  click_button 'Revoke'
end

Then(/^searching the public register for '(.+)' should return (\d+) records{0,1}$/) do |search_term, expected_record_count|
  visit public_path
  fill_in 'q', with: search_term    # 'q' is the 'Name of organisation' field.
  click_button 'reg-search'
  page.should have_content "Showing #{expected_record_count} of #{expected_record_count}"
end

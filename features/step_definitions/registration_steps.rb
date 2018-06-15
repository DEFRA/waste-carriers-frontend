Then(/^I should see the Finish page$/) do
  expect(page).to have_text 'The registration number is'
  expect(page).to have_button 'finished_btn'
end

When(/^I search for and revoke the first registration that matches the text '(.+)'$/) do |search_text|
  waitForSearchResultsToContainElementWithId(search_text, 'searchResult1')
  click_link 'revokeRegistration1'
  fill_in 'registration_metaData_revokedReason',
          with: 'revoked by cucumber test'
  click_button 'revokeButton'
end

When(/^I search for and approve the first registration that matches the text '(.+)'$/) do |search_text|
  waitForSearchResultsToContainElementWithId(search_text, 'searchResult1')
  click_link 'approveRegistration1'
  fill_in 'registration_metaData_approveReason',
          with: 'approved by cucumber test'
  click_button 'approveButton'
end

Then(/^when I repeat the search for '(.+)', the registration can no longer be approved$/) do |search_text|
  waitForSearchResultToPassLambda(
    search_text,
    lambda {|page| !(page.has_xpath?("//*[@id = 'approveRegistration1']")) })
  expect(page).not_to have_link 'approveRegistration1'
end

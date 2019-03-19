Given(/^I fill out the upper tier steps$/) do
  step 'I have been funneled into the upper tier path'
  step 'I am a carrier dealer'
  step 'I enter my business details'
  step 'I enter my contact details'
  postal_address_page_complete_form
  step 'I enter the details of the business owner'
end

And(/^I declare convictions$/) do
  choose 'Yes'
  click_button 'continue'
end

And(/^I do not declare convictions$/) do
  choose 'No'
  click_button 'continue'
end

And(/^I enter convictee details$/) do
  fill_in 'First name', with: 'Barry'
  fill_in 'Last name', with: 'Butler'
  fill_in 'Position', with: 'Janitor'

  fill_in 'Day', with: '1'
  fill_in 'Month', with: '1'
  fill_in 'Year', with: '1970'

  click_button 'add_btn'

  click_button 'continue'
end

When(/^I come to the confirmation step$/) do
  # no-op
end

Then(/^I see I declared convictions$/) do
  expect(page).to have_text 'You told us you have relevant people with convictions in your business or organisation'
end

Then(/^I see I did not declare convictions$/) do
  expect(page).to have_text 'You told us there are no relevant people with convictions in your business or organisation'
end

Then(/^I see a link to edit my conviction declaration$/) do
  expect(page).to have_link 'Edit relevant convictions'
end

And(/^this takes me back to the conviction step$/) do
  click_link 'edit_conviction_declaration'
  expect(page).to have_text 'environmental offence in the last 12 months?'
end

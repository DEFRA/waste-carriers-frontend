Given(/^I fill out the upper tier steps$/) do
  step 'I have been funneled into the upper tier path'
  step 'I am a carrier dealer'
  step 'I enter my business details'
  step 'I enter my contact details'
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
  page.has_text? 'You told us you have relevant people with convictions in your business or organisation'
end

Then(/^I see I did not declare convictions$/) do
  page.has_text? 'You told us there are no relevant people with convictions in your business or organisation'
end

Then(/^I see a link to edit my conviction declaration$/) do
  page.should have_link 'Edit relevant convictions'
end

And(/^this takes me back to the conviction step$/) do
  click_link 'edit_conviction_declaration'
  page.has_text? 'environmental offence in the last 12 months?'
end

But(/^the convictions service says I am suspect$/) do
  allow_any_instance_of(ConvictionsCaller).to receive(:convicted?).and_return(true)
end

When(/^I come to the final step$/) do
  check 'registration_declaration'
  click_button 'confirm'

  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password
  click_button 'continue'

  choose 'registration_payment_type_bank_transfer'
  click_button 'proceed_to_payment'

  click_button 'continue'
end

Then(/^I am told my application is being checked$/) do
  page.has_text? 'Your registration is pending checks.'
end

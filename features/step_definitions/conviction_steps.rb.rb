Given(/^I fill out the upper tier steps$/) do
  step 'I have been funneled into the upper tier path'
  step 'I am a carrier dealer'
  step 'I enter my business details'
  step 'I enter my contact details'
  step 'I enter the details of the business owner'
end

And(/^I declare convictions$/) do
  choose 'Yes'
  click_on 'Next'
end

And(/^I do not declare convictions$/) do
  choose 'No'
  click_on 'Next'
end

And(/^I enter convictee details$/) do
  fill_in 'First name', with: 'Barry'
  fill_in 'Last name', with: 'Butler'
  fill_in 'Position', with: 'Janitor'

  fill_in 'Day', with: '1'
  fill_in 'Month', with: '1'
  fill_in 'Year', with: '1970'

  click_on 'Add another person'

  click_on 'Next'
end

When(/^I come to the confirmation step$/) do
  # no-op
end

Then(/^I see I declared convictions$/) do
  page.should have_content 'You have declared convictions'
end

Then(/^I see I did not declare convictions$/) do
  page.should have_content 'You have not declared any convictions'
end

Then(/^I see a link to edit my conviction declaration$/) do
  page.should have_link 'Edit your conviction declaration'
end

And(/^this takes me back to the conviction step$/) do
  click_on 'Edit your conviction declaration'
  page.should have_content 'any relevant convictions in the last 12 months?'
end

But(/^the convictions service says I am suspect$/) do
  allow_any_instance_of(ConvictionsCaller).to receive(:convicted?).and_return(true)
end

When(/^I come to the final step$/) do
  check 'registration_declaration'
  click_on 'Confirm'

  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password
  click_on 'Next'

  click_on 'Pay via electronic transfer'

  click_on 'Next'
end

Then(/^I am told my application is being checked$/) do
  page.should have_content 'Your registration is pending checks.'
end
Given(/^I fill out the upper tier steps$/) do
  step 'I have been funneled into the upper tier path'
  step 'I am a carrier dealer'
  step 'I enter my business details'
  step 'I enter my contact details'
  step 'I enter the details of the business owner'
  step 'no key people in the organisation have convictions'
end

When(/^I come to the confirmation step$/) do
  # no-op
end

Then(/^I see a link to edit my conviction declaration$/) do
  page.should have_link 'Edit your conviction declaration'
end

And(/^this takes me back to the conviction step$/) do
  click_on 'Edit your conviction declaration'
  page.should have_content 'any relevant convictions in the last 12 months?'
end
Given(/^I fill out the upper tier steps$/) do
  step 'I have been funneled into the upper tier path'
  step 'I am a carrier dealer'
  step 'I enter my business details'
  step 'I enter my contact details'
  step 'I enter the details of the business owner'
end

And(/^I do not declare any convictions$/) do
  choose 'No'
end

When(/^I come to the confirmation step$/) do
  click_on 'Next'
end

Then(/^I see my answer to the convictions question$/) do
  page.should have_content 'You have not declared any convictions'
end

Then(/^I see a link to edit my conviction declaration$/) do
  page.should have_link 'Edit your conviction declaration'
end

And(/^this takes me back to the conviction step$/) do
  click_on 'Edit your conviction declaration'
  page.should have_content 'any relevant convictions in the last 12 months?'
end
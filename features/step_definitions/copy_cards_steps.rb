Given(/^I have selected copy cards option for that registration$/) do
  page.should have_content 'Add copy cards'
  click_link 'addcopycards_'+@stored_value
end

When /^I will be prompted to fill in "([^"]*)" with "([^"]*)"$/ do |element, text|
  fill_in element, with: text
end

Then(/^I can choose to pay by card or electronic transfer$/) do
  page.has_button?('continue')
  page.has_button?('offline_continue')
end

Given(/^I'm on the copy cards payment summary page$/) do
  page.should have_content 'Copy cards'
end

Then(/^I will be shown confirmation of paid order$/) do
  # Payment Checks
  page.should have_content 'Your order has been sucessful'
  # Content specific checks
  page.should have_content 'Thank you for your copy card order'

  click_button 'finish'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'

  #pending # express the regexp above with the code you wish you had
end

Then(/^I will be shown confirmation of unpaid order$/) do
  # Payment Checks
  page.should have_content 'Almost there'
  # Content specific checks
  page.should have_content 'Thank you for your copy card order'

  click_button 'finish'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'

end

Then(/^I finish my registration$/) do
  # Perform this as it cleans the session variables
  click_button 'finish'
end

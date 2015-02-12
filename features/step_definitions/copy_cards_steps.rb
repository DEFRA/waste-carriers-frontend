When(/^I visit the Add Copy Cards page for my registration$/) do
  page.should have_content 'Add copy cards'
  click_link "addcopycards_#{@cucumber_reg_id}"
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
  page.should have_content 'Your order has been successful'
  # Content specific checks
  page.should have_content 'Thank you for your copy card order'

  click_link 'finished_btn'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'

  #pending # express the regexp above with the code you wish you had
end

Then(/^I will be shown confirmation of unpaid order$/) do
  # Payment Checks
  page.should have_content 'Almost There'   # TODO: Update this when the page wording is finalised
  # Content specific checks
  page.should have_content 'Thank you for your copy card order'

  click_link 'finished_btn'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'

end

Then(/^I finish my registration$/) do
  # Perform this as it cleans the session variables
  click_button 'finish'
end

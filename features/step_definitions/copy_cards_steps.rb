Given(/^I have selected copy cards option for that registration$/) do
  page.should have_content 'Add copy cards'
  puts 'Looking for add @stored_value: ' + @stored_value
  click_on 'addcopycards_'+@stored_value
end

When /^I will be prompted to fill in "([^"]*)" with "([^"]*)"$/ do |element, text|
  fill_in element, with: text
end

Then(/^I can choose to pay by card or electronic transfer$/) do
  page.has_button?('next')
  page.has_button?('offline_next')
end

Given(/^I'm on the copy cards payment summary page$/) do
  page.should have_content 'Copy cards'
end

# Removed as replaced with a check on Worldpay's page rather than reply on JS on the current page
#Given(/^Total charge will be (\d+)\.(\d+)$/) do |arg1, arg2|
#  totalParams = arg1 + '.' + arg2
#  # both the total fee and copy card fee should be the same
#  totalValue = find_by_id('registration_copy_card_fee').value.to_s
#  #totalValue = find_by_id('registration_total_fee').value.to_s
#  totalValue.should equal totalParams
#end

Then(/^I will be shown confirmation of paid order$/) do  
  # Payment Checks
  page.should have_content 'Your order has been sucessful'
  # Content specific checks
  page.should have_content 'Thank you for your copy card order'
  
  click_on 'Finish'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'  
  
  #pending # express the regexp above with the code you wish you had
end

Then(/^I will be shown confirmation of unpaid order$/) do  
  # Payment Checks
  page.should have_content 'Almost there'
  # Content specific checks
  page.should have_content 'Thank you for your copy card order'
  
  click_on 'Finish'
  # Check routing after clicking finish
  page.should have_content 'Your registrations'  
  
end

Then(/^I finish my registration$/) do
  # Perform this as it cleans the session variables 
  click_on 'Finish'
end
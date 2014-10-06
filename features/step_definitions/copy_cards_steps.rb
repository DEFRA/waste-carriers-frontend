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

Given(/^Total charge will be (\d+)\.(\d+)$/) do |arg1, arg2|
  totalParams = arg1 + '.' + arg2
  # both the total fee and copy card fee should be the same
  totalValue = find_by_id('registration_copy_card_fee').value.to_s
  #totalValue = find_by_id('registration_total_fee').value.to_s
  totalValue.should equal totalParams
end

Then(/^I will be shown confirmation of order$/) do
  pending # express the regexp above with the code you wish you had
end
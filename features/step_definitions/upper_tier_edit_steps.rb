Given(/^The edit link is available$/) do
  page.should have_content 'Edit Registration'
  page.should have_link('edit_'+@stored_value)
end

Then(/^I click the edit link for: (.*)$/) do |name|
  # Uses the saved registration ID to find the correct registration to renew
  puts 'Using registration id: ' + @stored_value
  click_on 'edit_'+@stored_value
end

Then(/^I check that no changes have occurred$/) do
  page.should have_content 'Your registrations'
  page.should have_content 'Edit Registration'
end

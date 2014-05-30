Then(/^I select business or organisation type "(.*?)"$/) do |field_value|
  choose field_value
end

Then(/^I should see the Confirmation page$/) do
  page.should have_content 'is registered'
  page.should have_button 'Finished'
end

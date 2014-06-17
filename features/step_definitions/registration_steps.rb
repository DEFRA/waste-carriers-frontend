Then(/^I should see the Confirmation page$/) do
  page.should have_content 'is registered'
  page.should have_button 'Finished'
end

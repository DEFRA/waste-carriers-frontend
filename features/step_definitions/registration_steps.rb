Then(/^I should see the Finish page$/) do
  page.should have_content 'The registration number is'
  page.should have_button 'finished_btn'
end

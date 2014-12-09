  
Given(/^I change business type to Sole Trader$/) do
  choose 'registration_businessType_soletrader'
  click_on 'Next'
end

 Then(/^I should be told that I have to start a new registration$/) do
  page.should have_content 'new upper tier registration will be made and will require a payment of £154.00'
end

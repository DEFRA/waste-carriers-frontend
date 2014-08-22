And(/^I pay by card$/) do
  click_on 'Pay by debit/credit card'

  click_on 'MasterCard'

  fill_in 'Card number', with: '4444333322221111'
  select '12', from: 'cardExp.month'
  select Date.current.year + 2, from: 'cardExp.year'
  fill_in "Cardholder's name", with: 'B Butler'
  fill_in 'Address 1', with: 'Deanery St.'
  fill_in 'Town/City', with: 'Bristol'
  fill_in 'Postcode/ZIP', with: 'BS1 5AH'
  click_on 'op-PMMakePayment'

  step 'I set test simulator page to all okay'
end

Then(/^I set test simulator page to all okay$/) do
  sleep 2.5
  #By now we should be on the Test Simulator page...
  page.should have_content 'Secure Test Simulator Page'
  click_on 'Continue'

  #add some sleep to avoid failing tests
  sleep 1.0
end

When(/^I provide valid credit card payment details on behalf of a caller$/) do
  #Select MasterCard by clicking on the button:
  sleep 1.0

  page.should have_content 'Secure Payment Page'

  page.should have_content 'MasterCard'

  click_on 'MasterCard'

  #These are valid card numbers for the WorldPay Test Service. See the WorldPay XML Redirect Guide for details
  fill_in 'cardNoInput', with: '4444333322221111'
  fill_in 'cardCVV', with: '123'
  select('12', from: 'cardExp.month')
  select(Date.current.year + 2, from: 'cardExp.year')
  fill_in 'name', with: 'Mr Waste Carrier'
  fill_in 'address1', with: 'Upper Waste Carrier Street'
  fill_in 'town', with: 'Upper Town'
  fill_in 'postcode', with: 'BS1 5AH'
  click_on 'op-PMMakePayment'

  step 'I set test simulator page to all okay'
end

And(/^I choose to pay by bank transfer$/) do
  click_on 'Pay via electronic transfer'
end

Then(/^I make a note of the details$/) do
  page.text.should match /CBDU\d+/
  page.text.should match /Sort code/
  page.text.should match /Account number/

  click_on 'Next'
end

Then(/^my upper tier waste carrier registration is pending until payment is received by the Environment Agency$/) do
  page.should have_content 'registration number: CBDU'
  page.should have_content 'Please remember to arrange your bank transfer'
end

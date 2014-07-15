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

  sleep 1.5
  click_on 'Continue'
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

  sleep 1.5
  #By now we should be on the Test Simulator page...
  page.should have_content 'Secure Test Simulator Page'
  #The standard 'approved' etc. should already be selected, just click the 'continue' button (input)
  #click_on 'continue'
  first(:xpath,'/html/body/table/tbody/tr/td/table/tbody/tr[3]/td/table/tbody/tr[1]/td[2]/form/table/tbody/tr/td/table/tbody/tr[6]/td/label/nobr/input').click

  #add some sleep to avoid failing tests
  sleep 1.0
end

And(/^I choose to pay by bank transfer$/) do
  click_on 'Pay via electronic transfer'
end

Then(/^I make a note of the details$/) do
  page.text.should match /Payment reference number: CBDU\d+/
  page.text.should match /Sort code: \d{2}-\d{2}-\d{2}/
  page.text.should match /Account number: \d+/

  click_on 'Next'
end

Then(/^my upper tier waste carrier registration is pending until payment is received by the Environment Agency$/) do
  page.should have_content 'Your registration number is: CBDU'
  page.should have_content 'Your registration is pending payment'
end
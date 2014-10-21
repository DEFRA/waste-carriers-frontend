#
# Helper function to help wait untill we have left the worldpay site
#
def waitForWorldpayRedirect
  # Check if on the worldpay is waiting for redirect page. This often results in the browser client side redirecting to
  # an page in our site that is no longer available as the tests have moved on by the time the redirect occurs
  waitMessage1 = 'Please wait for the result.'
  waitMessage2 = 'Please wait while your payment'
  if page.body.to_s.include?(waitMessage1) || page.body.to_s.include?(waitMessage2)
    puts '... Waiting 5 seconds for worldpay to respond'
    sleep 5.0

    if page.body.to_s.include?(waitMessage1) || page.body.to_s.include?(waitMessage2)
      puts '... Waiting a further 10 seconds for worldpay to respond'
      sleep 10.0

      if page.body.to_s.include?(waitMessage1) || page.body.to_s.include?(waitMessage2)
        puts '... Waiting a final 10 seconds for worldpay to respond'

        sleep 10.0

        if page.body.to_s.include?(waitMessage1) || page.body.to_s.include?(waitMessage2)
          puts 'Warning: Not redirecting out of worldpay, if the following test fails, it is likely because this route never left worldpay'
        end
      end
    end

    # If neccesary change default wait time for capybara commands to wait longer for content to appear
    #default_wait_time = Capybara.default_wait_time
    #Capybara.default_wait_time = 5 # Really long request
    #Capybara.default_wait_time = default_wait_time
  end
end

And(/^I pay by card$/) do
  click_on 'Pay by credit or debit card'

  sleep 0.5

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

And(/^I pay by card ensuring the total amount is (\d+)\.(\d+)$/) do |arg1, arg2|
  click_on 'Pay by credit or debit card'

  sleep 0.5

  # Build test parameter to compare to worldpay test page
  totalParams = 'GBP ' + arg1 + '.' + arg2
  # Get amount value from worldpay page
  worldpayAmount = find(:xpath, '//body/table/tbody/tr/td/table/tbody/tr[3]/td/table/tbody/tr[1]/td[2]/form/table/tbody/tr/td/table/tbody/tr[4]/td/table/tbody/tr[2]/td[2]/span/b').text
  # Check worldpay site matches expected value
  worldpayAmount.should match totalParams

  # Continue with Worlpay payment
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
  sleep 3.0
  #By now we should be on the Test Simulator page...
  page.should have_content 'Secure Test Simulator Page'
  click_on 'Continue'

  # Wait for worldpay redirect to occur
  waitForWorldpayRedirect
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
  click_on 'Pay by bank transfer'
end

And(/^I choose pay via electronic transfer ensuring the total amount is (\d+)\.(\d+)$/) do |arg1, arg2|
  click_on 'Pay by bank transfer'

  # Build test parameter to compare to offline payment page
  totalParams = '£' + arg1 + '.' + arg2
  # Get amount value from offline payment page
  offlineAmount = find_by_id('payment-table-wrapper').find(:xpath, '//table[1]/tbody/tr[2]/td[2]').text
  # Check worldpay site matches expected value
  offlineAmount.should match totalParams

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

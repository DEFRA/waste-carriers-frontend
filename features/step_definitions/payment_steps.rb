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

def waitForWorldpayToLoad
  expectedWorldpayContent1 = 'Secure Payment Page'
  if !page.body.to_s.include?(expectedWorldpayContent1)
    puts '... Waiting 3 seconds for worldpay to load'
    sleep 3.0
  end
end

And(/^I pay by card$/) do
  expect(page).to have_text 'Payment summary'

  choose 'registration_payment_type_world_pay'
  click_button 'proceed_to_payment'

  sleep 0.5

  # Wait a period for worldpay to load
  waitForWorldpayToLoad

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

And(/^I choose to pay by bank transfer$/) do
  choose 'registration_payment_type_bank_transfer'
  click_button 'proceed_to_payment'
end

Then(/^I make a note of the details$/) do
  expect(page).to have_text /CBDU\d+/
  expect(page).to have_text /Sort code/
  expect(page).to have_text /Account number/

  click_button 'continue'
end

Then(/^my upper tier waste carrier registration is pending until payment is received by the Environment Agency$/) do
  expect(page).to have_text 'Please use this reference number if you contact us:'
  expect(page).to have_text 'Please allow 5 working days for your payment to reach us'
end

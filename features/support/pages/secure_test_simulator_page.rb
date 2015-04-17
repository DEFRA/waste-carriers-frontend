module SecureTestSimulatorPage
  def secure_test_simulator_page_continue
   click_on 'Continue'
   
   # Need to wait until we are re-directed back to our site.
   total_wait_time = 0
   loop do
     break if !page.current_url.include?('worldpay.com') || (total_wait_time > 20)
     puts '... Waiting 1 second for WorldPay re-direct... '\
          '(maximum wait time is 20 seconds)'
     sleep 1
     total_wait_time += 1
   end
   expect(page.current_url.include?('worldpay.com')).to be_falsy
   
  end
end
World(SecureTestSimulatorPage)

module ComfirmedPage
  def confirmed_page_finish_registration()
    click_button 'finished'
  end

    def confirmed_page_check_text_registration_complete()
    page.has_content? 'Registration complete'
  end

  def confirmed_page_check_pending_convictions_text()
  	page.should have_content 'Application received'
    end

   def confirmed_page_check_pending_payment_text
   page.should have_content 'pay the registration fee'
   end

   def confirmed_page_check_charge_amount(amount:'105.00')
   totalChargeAmount = find(:xpath, '//*[@id="payment-table-wrapper"]/table[1]/tbody/tr[2]/td[2]').text
   expect(totalChargeAmount).to have_text "#{amount}"
   # pp totalChargeAmount
   end
end
World(ComfirmedPage)

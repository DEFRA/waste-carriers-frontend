module FinishAssistedPage
  def finish_assisted_page_check_registration_complete_text()
  page.should have_content 'Registration complete'
  page.should have_content 'has been registered as an upper tier waste carrier'

  # validate the access code is present and of the correct length
  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
    end

   def finish_assisted_page_check_pending_convictions_text()
  page.should have_content 'Registration pending'
  page.should have_content 'The applicant declared relevant people with convictions so these will need to be cross checked before the registration can be completed'

  # validate the access code is present and of the correct length
  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
    end

   def finish_assisted_page_check_pending_payment_text(amount:'105.00')
   page.should have_content 'pay the registration fee'
   totalChargeAmount = find(:xpath, '//*[@id="payment-table-wrapper"]/table[1]/tbody/tr[2]/td[2]').text
   expect(totalChargeAmount).to have_text "#{amount}"
   # pp totalChargeAmount

    end

end
World(FinishAssistedPage)
module SecurePaymentDetailsPage
  def secure_payment_details_page_enter_mastercard_details_and_submit()
  fill_in 'Card number', with: '4444333322221111'
  select '12', from: 'cardExp.month'
  select Date.current.year + 2, from: 'cardExp.year'
  fill_in "Cardholder's name", with: 'B Butler'
  fill_in 'Address 1', with: 'Deanery St.'
  fill_in 'Town/City', with: 'Bristol'
  fill_in 'Postcode/ZIP', with: 'BS1 5AH'
  click_on 'op-PMMakePayment'
   end
 def secure_payment_details_page_enter_visa_details_and_submit()
  fill_in 'Card number', with: '4444333322221111'
  select '12', from: 'cardExp.month'
  select Date.current.year + 2, from: 'cardExp.year'
  fill_in "Cardholder's name", with: 'B Butler'
  fill_in 'Address 1', with: 'Deanery St.'
  fill_in 'Town/City', with: 'Bristol'
  fill_in 'Postcode/ZIP', with: 'BS1 5AH'
  click_on 'op-PMMakePayment'  
  end
 def secure_payment_details_page_enter_maestro_details_and_submit()
  fill_in 'Card number', with: '4444333322221111'
  select '12', from: 'cardExp.month'
  select Date.current.year + 2, from: 'cardExp.year'
  fill_in "Cardholder's name", with: 'B Butler'
  fill_in 'Address 1', with: 'Deanery St.'
  fill_in 'Town/City', with: 'Bristol'
  fill_in 'Postcode/ZIP', with: 'BS1 5AH'
  click_on 'op-PMMakePayment'  
  end
  def secure_payment_details_page_check_worldpay_amount(amount: '154.00')
  # Get amount value from worldpay page
  worldpayAmount = find(:xpath, '//body/table/tbody/tr/td/table/tbody/tr[3]/td/table/tbody/tr[1]/td[2]/form/table/tbody/tr/td/table/tbody/tr[3]/td/table/tbody/tr[4]/td[2]/span/b').text
  worldpayAmount.should match "GBP #{amount}"
  end
  def secure_payment_details_page_check_bank_transfer_amount(amount: '154.00')
  # Get amount value from bank transfer page
  bankTransferAmount = find(:xpath, '//*[@id="payment-table-wrapper"]/table[1]/tbody/tr[2]/td[2]').text
  bankTransferAmount.should match "£#{amount}"
  end
end
World(SecurePaymentDetailsPage)

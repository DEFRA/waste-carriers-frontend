module OrderPage
  def order_page_complete_order_pay_by_world_pay_and_submit(number)
    fill_in 'registration_copy_cards', with: number
    choose 'registration_payment_type_world_pay'
    click_button 'proceed_to_payment'
  end

  def order_page_complete_order_pay_by_bank_transfer_and_submit(number)
    fill_in 'registration_copy_cards', with: number
    choose 'registration_payment_type_bank_transfer'
    click_button 'proceed_to_payment'
  end

  def order_page_complete_order_pay_check_total_charge(amount:'105.00')
   # totalChargeAmount = find(:xpath, '//*[@id="registration_registration_fee"]').text
   totalChargeAmount = find(:xpath, '//*[@id="registration_total_fee"]').text
   # puts totalChargeAmount
   totalChargeAmount.should match "#{amount}"
  end

end
World(OrderPage)

module OrderPage
  def order_page_pay_by_world_pay_and_submit(number)
    fill_in 'registration_copy_cards', with: number
    choose 'registration_payment_type_world_pay'
    click_button 'proceed_to_payment'
  end

  def order_page_pay_by_bank_transfer_and_submit(number)
    fill_in 'registration_copy_cards', with: number
    choose 'registration_payment_type_bank_transfer'
    click_button 'proceed_to_payment'
  end

    def order_page_pay_ir_by_bank_transfer_and_submit(number)
    # currently no option to order copy cards for IR online registrations
    # fill_in 'registration_copy_cards', with: number
    choose 'registration_payment_type_bank_transfer'
    click_button 'proceed_to_payment'
  end

  def order_page_check_registration_fee(amount:'105.00')
   totalChargeAmount = find(:xpath, '//*[@id="registration_registration_fee"]').value
   expect(totalChargeAmount).to have_text "#{amount}"
  end

  def order_page_confirm_registration_fee(total_fee)
   totalChargeAmount = find(:xpath, '//*[@id="registration_registration_fee"]').value
   expect(totalChargeAmount).to have_text "#{total_fee}"
  end

  def order_page_check_total_charge(amount:'105.00')
   totalChargeAmount = find(:xpath, '//*[@id="registration_total_fee"]').value
   # pp totalChargeAmount
   expect(totalChargeAmount).to have_text "#{amount}"
  end

  def order_page_enter_copy_cards(no_of_cards: 3)
   fill_in 'registration_copy_cards', with: no_of_cards.to_i
  end

  def order_page_pay_by_credit_card(submit: true)
    choose 'registration_payment_type_world_pay'
    order_page_submit if submit
  end

  def order_page_pay_by_bank_transfer(submit: true)
    choose 'registration_payment_type_bank_transfer'
    order_page_submit if submit
  end

  def order_page_submit
    click_button 'proceed_to_payment'
  end

end
World(OrderPage)

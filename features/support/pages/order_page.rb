module OrderPage
  def complete_order_pay_by_world_pay_and_submit(number)
    fill_in 'registration_copy_cards', with: number
    choose 'registration_payment_type_world_pay'
    click_button 'proceed_to_payment'
  end

  def complete_order_pay_by_bank_transfer_and_submit(number)
    fill_in 'registration_copy_cards', with: number
    choose 'registration_payment_type_bank_transfer'
    click_button 'proceed_to_payment'
  end
end
World(OrderPage)
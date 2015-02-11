module OrderPage
  def complete_order_pay_by_world_pay_and_submit(number)
    fill_in 'registration_copy_cards', with: number
    click_button 'worldpay_button'
  end

  def complete_order_pay_by_bank_transfer_and_submit(number)
    fill_in 'registration_copy_cards', with: number
    click_button 'offline_pay_button'
  end
end
World(OrderPage)
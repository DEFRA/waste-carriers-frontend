module YourRegistrationOrderPage
  def your_registration_order_page_enter_copy_cards(no_of_cards: 3)
   fill_in 'registration_copy_cards', with: no_of_cards.to_i
   end
  def your_registration_order_page_pay_by_credit_card()
    choose 'registration_payment_type_world_pay'
    click_button 'proceed_to_payment'
  end
end
World(YourRegistrationOrderPage)

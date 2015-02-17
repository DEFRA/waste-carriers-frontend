module YourRegistrationOrderPage
  def your_registration_order_page_enter_copy_cards(no_of_cards: 3)
   fill_in 'registration_copy_cards', with: no_of_cards.to_i
   end
  def your_registration_order_page_pay_by_credit_card()
   click_button 'worldpay_button'
  end
end
World(YourRegistrationOrderPage)

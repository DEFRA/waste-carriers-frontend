module YourRegistrationOrderPage
  def your_registration_order_page_enter_copy_cards(no_of_cards: 3)
   fill_in 'registration_copy_cards', with: no_of_cards.to_i
   end
   
   def your_registration_order_page_pay_by_credit_card(submit: 'true')
    choose 'registration_payment_type_world_pay'
    your_registration_order_page_submit if submit
   end

   def your_registration_order_page_pay_by_bank_transfer(submit: 'true')
    choose 'registration_payment_type_bank_transfer'
    your_registration_order_page_submit if submit
   end

   def your_registration_order_page_submit
    click_button 'proceed_to_payment'
   end
end
World(YourRegistrationOrderPage)

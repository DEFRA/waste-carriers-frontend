module PaymentCopyCardsComplete
  def payment_copy_cards_complete_check_order()
     page.has_text? 'Thank you for your copy card order'
   end

end
World(PaymentCopyCardsComplete)

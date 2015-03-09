module PaymentCopyCardsComplete
  def payment_copy_cards_complete_check_order()
     expect(page).to have_text 'Thank you for your copy card order'
   end

end
World(PaymentCopyCardsComplete)

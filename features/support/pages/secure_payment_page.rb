module SecurePaymentPage
  def secure_payment_page_pay_by_mastercard()
   click_on 'MasterCard'
   end
  def secure_payment_page_pay_by_visa()
   click_on 'Visa'
   end

   def secure_payment_page_pay_by_maestro()
   click_on 'Maestro'
   end
end
World(SecurePaymentPage)





module ConfirmationPage
  def confirm_registration_and_submit()
    check 'registration_declaration'
    submit_confirmation_page
  end

  def submit_confirmation_page()
    click_on 'Confirm'
  end
end
World(ConfirmationPage)

module SignupPage
  def enter_email_details_and_submit()
    fill_in 'registration_accountEmail', with: my_email_address
    fill_in 'registration_accountEmail_confirmation', with: my_email_address
    fill_in 'registration_password', with: my_password
    fill_in 'registration_password_confirmation', with: my_password
    submit_signup_page
  end

  def submit_signup_page()
    click_on 'Next'
  end
end
World(SignupPage)

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

module OfflinePaymentPage
  def complete_offline_payment()
    click_button 'next'
  end
end
World(OfflinePaymentPage)

module ComfirmedPage
  def finish_registration()
    click_button 'finished'
  end
end
World(ComfirmedPage)

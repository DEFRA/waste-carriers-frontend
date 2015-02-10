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
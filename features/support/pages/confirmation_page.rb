module ConfirmationPage
  def confirmation_page_registration_and_submit()
    check 'registration_declaration'
    confirmation_page_submit
  end

   def confirmation_page_registration_check_for_renewal_text()
    page.should have_content 'Renewing your registration'
  end

  def confirmation_page_submit()
    click_button 'confirm'
  end
end
World(ConfirmationPage)


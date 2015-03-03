module ConfirmationPage
  def confirmation_page_registration_and_submit()
    check 'registration_declaration'
    confirmation_page_submit
  end

   def confirmation_page_registration_check_for_renewal_text()
    page.should have_content 'Renewing your registration'
  end

     def confirmation_page_registration_check_for_new_registration_text()
    page.should have_content 'Please be aware that the changes you have made means that a new upper tier registration will be made and will require a payment of £154.00'
    # page.should have_content 'you told us'
  end

  def confirmation_page_submit()
    click_button 'confirm'
  end
end
World(ConfirmationPage)


# Helper used in testing for working with the confirmation page.
module ConfirmationPage
  def confirmation_page_registration_and_submit
    check 'registration_declaration'
    confirmation_page_submit
  end

  def confirmation_page_registration_check_for_renewal_text
    expect(page).to have_text 'You are about to renew your registration'
  end

  def confirmation_page_registration_check_for_expired_renewal_text
    expect(page).to have_text 'Your previous registration has expired. This is a new registration'
  end

  def confirmation_page_submit
    click_button 'confirm'
  end
end
World(ConfirmationPage)

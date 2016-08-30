# Helper used in testing for working with the confirmation page.
module ConfirmationPage
  def confirmation_page_agree_to_declaration_and_submit
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

  def confirmation_page_click_edit_business_address_link
    click_link 'Edit your business or organisation address'
  end

  def confirmation_page_check_business_address_has_changed
    expect(page).to have_text 'HARMSEN GROUP'
    expect(page).not_to have_text 'ENVIRONMENT AGENCY'
  end
end
World(ConfirmationPage)

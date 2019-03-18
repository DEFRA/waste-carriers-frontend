module UserRegistrationsPage
  def user_registrations_page_add_copy_cards()
    click_on 'Order copy cards'
    expect(page).to have_text 'Copy cards'
  end

  def user_registrations_page_click_edit_registration_link()
    click_on 'Edit registration'
    expect(page).to have_text 'Check your details before registering'
  end

  def user_registrations_page_sign_out_user()
    logout(:user)
    # This doesn't work because of some Devise stuff.  Hence using the Warden
    # helper above.
    # click_button 'signout_button'
  end
end

World(UserRegistrationsPage)

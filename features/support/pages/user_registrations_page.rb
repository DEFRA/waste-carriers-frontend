module UserRegistrationsPage
  def user_registrations_page_add_copy_cards()
   click_on 'Order copy cards'
    expect(page).to have_text 'Copy cards'
  end
end
World(UserRegistrationsPage)

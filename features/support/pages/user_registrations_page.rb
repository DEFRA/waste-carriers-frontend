module UserRegistrationsPage
  def user_registrations_page_add_copy_cards()
   click_on 'Add copy cards'
    page.has_text? 'Copy cards'
  end
end
World(UserRegistrationsPage)

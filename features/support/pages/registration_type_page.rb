# Helper used in testing for working with the registration type page.
module RegistrationTypePage
  def go_to
    visit registration_type_path
  end

  def registration_type_page_select_
    choose ''
  end

  def registration_type_page_select_
    choose ''
  end

  def registration_type_page_select_
    choose ''
  end

  def registration_type_page_submit
    click_button 'next'
  end
end
World(RegistrationTypePage)

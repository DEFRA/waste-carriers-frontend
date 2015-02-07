# Helper used in testing for working with the registration type page.
module RegistrationTypePage
  def go_to
    visit registration_type_path
  end

  def select_and_submit(value)
    choose(value)
    submit
  end

  def submit
    click_button 'Next'
  end
end
World(RegistrationTypePage)

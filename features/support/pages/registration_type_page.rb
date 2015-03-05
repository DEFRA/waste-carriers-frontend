# Helper used in testing for working with the registration type page.
module RegistrationTypePage
  def go_to
    visit registration_type_path
  end

  def registration_type_page?
    page.expect(page).to have_css 'a[data-journey$="registration-type"]'
  end

  def registration_type_page_select_carrier_dealer(submit: 'true')
    choose 'registration_registrationType_carrier_dealer'
    registration_type_page_submit if submit
  end

  def registration_type_page_select_broker_dealer(submit: 'true')
    choose 'registration_registrationType_broker_dealer'
    registration_type_page_submit if submit
  end

  def registration_type_page_select_carrier_broker_dealer(submit: 'true')
    choose 'registration_registrationType_carrier_broker_dealer'
    registration_type_page_submit if submit
  end

  def registration_type_page_submit
    click_button 'continue'
  end
end
World(RegistrationTypePage)

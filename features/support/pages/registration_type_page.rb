# Helper used in testing for working with the registration type page.
module RegistrationTypePage
  def go_to
    visit registration_type_path
  end

  def registration_type_page_select_carrier_dealer
    choose 'registration_registrationType_carrier_dealer'
  end

  def registration_type_page_select_broker_dealer
    choose 'registration_registrationType_broker_dealer'
  end

  def registration_type_page_select_carrier_broker_dealer
    choose 'registration_registrationType_carrier_broker_dealer'
  end

  def registration_type_page_submit
    click_button 'next'
  end
end
World(RegistrationTypePage)

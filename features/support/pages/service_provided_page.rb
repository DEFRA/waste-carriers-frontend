# Helper used in testing for working with the service provided page.
module ServiceProvidedPage
  def go_to_service_provided_page
    visit construction_demolition_path
  end

  def service_provided_page_select_no
    choose 'registration_isMainService_no'
  end

  def service_provided_page_select_yes
    choose 'registration_isMainService_yes'
  end

  def service_provided_page_submit
    click_button 'next'
  end
end
World(ServiceProvidedPage)

# Helper used in testing for working with the service provided page.
module ServiceProvidedPage
  def go_to_service_provided_page
    visit construction_demolition_path
  end

  def service_provided_page_select(value)
    choose value
  end

  def service_provided_page_submit
    click_button 'Next'
  end

  def service_provided_page_select_and_submit(value)
    service_provided_page_select value
    service_provided_page_submit
  end
end
World(ServiceProvidedPage)

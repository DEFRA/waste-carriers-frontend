# Helper used in testing for working with the service provided page.
module ServiceProvidedPage
  def go_to_service_provided_page
    visit construction_demolition_path
  end

  def service_provided_page?
    expect(page).to have_css 'div[data-journey$="serviceprovided"]'
  end

  def service_provided_page_select_no(submit: 'true')
    choose 'registration_isMainService_no'
    service_provided_page_submit if submit
  end

  def service_provided_page_select_yes(submit: 'true')
    choose 'registration_isMainService_yes'
    service_provided_page_submit if submit
  end

  def service_provided_page_submit
    click_button 'continue'
  end
end
World(ServiceProvidedPage)

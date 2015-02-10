module StartPage
  def start_new_registration_and_submit(type)
    visit start_path
    choose (type)
    submit_start_page
  end

  def submit_start_page()
    click_button 'continue'
  end
end
World(StartPage)

module BusinessTypePage
  def select_business_type_and_submit(type)
    choose(type)
    submit_business_type_page
  end

  def submit_business_type_page()
    click_button 'continue'
  end
end
World(BusinessTypePage)

module OtherBusinessPage
  def select_other_business_and_submit(value)
    choose(value)
    submit_other_business_page
  end

  def submit_other_business_page()
    click_button 'continue'
  end
end
World(OtherBusinessPage)

module ConstructinDemolitionPage
  def select_construction_demolition_and_submit(value)
    choose(value)
    submit_construction_demolition_page
  end

  def submit_construction_demolition_page()
    click_button 'continue'
  end
end
World(ConstructinDemolitionPage)

module ServiceProvidedPage
  def select_service_provided_and_submit(value)
    choose(value)
    submit_service_provided_page
  end

  def submit_service_provided_page()
    click_button 'continue'
  end
end
World(ServiceProvidedPage)

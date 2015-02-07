# Helper used in testing for working with the business type page.
module BusinessTypePage
  def go_to_business_type_page
    visit business_type_path
  end

  def business_type_page_select(value)
    choose value
  end

  def business_type_page_submit
    click_button 'Next'
  end

  def business_type_page_select_and_submit(value)
    business_type_page_select value
    business_type_page_submit
  end
end
World(BusinessTypePage)

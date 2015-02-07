# Helper used in testing for working with the other business page.
module OtherBusinessesPage
  def go_to_other_businesses_page
    visit other_business_path
  end

  def other_businesses_page_select(value)
    choose value
  end

  def other_businesses_page_submit
    click_button 'Next'
  end

  def other_businesses_page_select_and_submit(value)
    other_businesses_page_select value
    other_businesses_page_submit
  end
end
World(OtherBusinessesPage)

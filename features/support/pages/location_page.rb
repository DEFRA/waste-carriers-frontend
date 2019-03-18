# Helper used in testing for working with the location page.
module LocationPage

  def location_page?
    expect(page).to have_css 'div[data-journey$="location"]'
  end

  def location_page_select_england(submit: 'true')
    choose 'registration_location_england'
    location_page_submit if submit
  end

  def location_page_select_wales(submit: 'true')
    choose 'registration_location_wales'
    location_page_submit if submit
  end

  def location_page_select_northern_ireland(submit: 'true')
    choose 'registration_location_northern_ireland'
    location_page_submit if submit
  end

  def location_page_select_overseas(submit: 'true')
    choose 'registration_location_overseas'
    location_page_submit if submit
  end

  def location_page_submit
    click_button 'continue'
  end
end
World(LocationPage)

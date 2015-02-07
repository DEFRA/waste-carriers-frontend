# Helper used in testing for working with the construction/demolition page.
module ConstructionDemolitionPage
  def go_to_construction_demolition_page
    visit construction_demolition_path
  end

  def construction_demolition_page_select(value)
    choose value
  end

  def construction_demolition_page_submit
    click_button 'Next'
  end

  def construction_demolition_page_select_and_submit(value)
    construction_demolition_page_select value
    construction_demolition_page_submit
  end
end
World(ConstructionDemolitionPage)

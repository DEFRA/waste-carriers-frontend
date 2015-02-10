# Helper used in testing for working with the construction/demolition page.
module ConstructionDemolitionPage
  def go_to_construction_demolition_page
    visit construction_demolition_path
  end

  def construction_demolition_page_select_no
    choose 'registration_constructionWaste_no'
  end

  def construction_demolition_page_select_yes
    choose 'registration_constructionWaste_yes'
  end

  def construction_demolition_page_submit
    click_button 'next'
  end
end
World(ConstructionDemolitionPage)

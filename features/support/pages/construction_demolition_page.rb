# Helper used in testing for working with the construction/demolition page.
module ConstructionDemolitionPage
  def go_to_construction_demolition_page
    visit construction_demolition_path
  end

  def construction_demolition_page?
    page.has_css? 'a[data-journey$="constructiondemolition"]'
  end

  def construction_demolition_page_select_no(submit: 'true')
    choose 'registration_constructionWaste_no'
    construction_demolition_page_submit if submit
  end

  def construction_demolition_page_select_yes(submit: 'true')
    choose 'registration_constructionWaste_yes'
    construction_demolition_page_submit if submit
  end

  def construction_demolition_page_submit
    click_button 'continue'
  end
end
World(ConstructionDemolitionPage)

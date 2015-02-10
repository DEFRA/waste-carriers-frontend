# Helper used in testing for working with the other business page.
module OtherBusinessesPage
  def go_to_other_businesses_page
    visit other_business_path
  end

  def other_businesses_page_select_no(submit: 'true')
    choose 'registration_otherBusinesses_no'
    other_businesses_page_submit if submit
  end

  def other_businesses_page_select_yes(submit: 'true')
    choose 'registration_otherBusinesses_yes'
    other_businesses_page_submit if submit
  end

  def other_businesses_page_submit
    click_button 'next'
  end
end
World(OtherBusinessesPage)

# Helper used in testing for working with the other business page.
module OtherBusinessesPage
  def go_to_other_businesses_page
    visit other_business_path
  end

  def other_businesses_page_select_no
    choose 'registration_otherBusinesses_no'
  end

  def other_businesses_page_select_yes
    choose 'registration_otherBusinesses_yes'
  end

  def other_businesses_page_submit
    click_button 'next'
  end
end
World(OtherBusinessesPage)

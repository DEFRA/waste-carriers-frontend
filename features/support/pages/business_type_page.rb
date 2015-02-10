# Helper used in testing for working with the business type page.
module BusinessTypePage
  def go_to_business_type_page
    visit business_type_path
  end

  def business_type_page_select_sole_trader
    choose 'registration_businessType_soletrader'
  end

  def business_type_page_select_partnership
    choose 'registration_businessType_partnership'
  end

  def business_type_page_select_limited_company
    choose 'registration_businessType_limitedcompany'
  end

  def business_type_page_select_public_body
    choose 'registration_businessType_publicbody'
  end

  def business_type_page_select_charity
    choose 'registration_businessType_charity'
  end

  def business_type_page_select_authority
    choose 'registration_businessType_authority'
  end

  def business_type_page_select_other
    choose 'registration_businessType_other'
  end

  def business_type_page_submit
    click_button 'next'
  end
end
World(BusinessTypePage)

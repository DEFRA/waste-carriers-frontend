# Helper used in testing for working with the business type page.
module BusinessTypePage
  def go_to_business_type_page
    visit business_type_path
  end

  def business_type_page?
    page.has_css? 'a[data-journey$="business-type"]'
  end

  def business_type_page_select_sole_trader(submit: 'true')
    choose 'registration_businessType_soletrader'
    business_type_page_submit if submit
  end

  def business_type_page_select_partnership(submit: 'true')
    choose 'registration_businessType_partnership'
    business_type_page_submit if submit
  end

  def business_type_page_select_limited_company(submit: 'true')
    choose 'registration_businessType_limitedcompany'
    business_type_page_submit if submit
  end

  def business_type_page_select_public_body(submit: 'true')
    choose 'registration_businessType_publicbody'
    business_type_page_submit if submit
  end

  def business_type_page_select_charity(submit: 'true')
    choose 'registration_businessType_charity'
    business_type_page_submit if submit
  end

  def business_type_page_select_authority(submit: 'true')
    choose 'registration_businessType_authority'
    business_type_page_submit if submit
  end

  def business_type_page_select_other(submit: 'true')
    choose 'registration_businessType_other'
    business_type_page_submit if submit
  end

  def business_type_page_submit
    click_button 'next'
  end
end
World(BusinessTypePage)

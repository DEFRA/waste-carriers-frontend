# Helper used in testing for working with the existing registration page.
module ExistingRegistrationPage
  def go_to_existing_registration_page
    visit construction_demolition_path
  end

  def existing_registration_page?
    page.has_css? 'a[data-journey$="existing-registration"]'
  end

  def existing_registration_page_complete_form(
    number: 'CB/AE9999XX/A001',
    submit: 'true')
    fill_in 'registration_originalRegistrationNumber', with: number
    existing_registration_page_submit if submit
  end

  def existing_registration_page_submit
    click_button 'continue'
  end

   def existing_registration_page_enter_limited_company_registration_number(submit: 'true')
      fill_in 'registration_originalRegistrationNumber', with: 'CB/AE9999XX/A001'
      existing_registration_page_submit if submit
  end

     def existing_registration_page_enter_sole_trader_registration_number(submit: 'true')
      fill_in 'registration_originalRegistrationNumber', with: 'CB/AN9999YY/R002'
      existing_registration_page_submit if submit
  end

     def existing_registration_page_enter_public_body_registration_number(submit: 'true')
      fill_in 'registration_originalRegistrationNumber', with: 'CB/VM9999WW/A001'
      existing_registration_page_submit if submit
  end

     def existing_registration_page_enter_partnership_registration_number(submit: 'true')
      fill_in 'registration_originalRegistrationNumber', with: 'CB/AN9999ZZ/R002 '
      existing_registration_page_submit if submit
  end

end
World(ExistingRegistrationPage)

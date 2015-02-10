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
end
World(ExistingRegistrationPage)

# Helper used in testing for working with the no registration page.
module NoRegistrationPage
  def go_to_no_registration_page
    visit no_registration_path
  end

  def no_registration_page?
    expect(page).to have_css 'div[data-journey$="noregistration"]'
  end
end
World(NoRegistrationPage)

module SignupPage
  def enter_email_details_and_submit()
    fill_in 'registration_accountEmail', with: my_email_address
    fill_in 'registration_accountEmail_confirmation', with: my_email_address
    fill_in 'registration_password', with: my_password
    fill_in 'registration_password_confirmation', with: my_password
    submit_signup_page
  end

  def submit_signup_page()
    click_button 'continue'
  end
end
World(SignupPage)
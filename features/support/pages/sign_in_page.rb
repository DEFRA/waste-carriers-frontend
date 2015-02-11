module SignInPage
  def sign_in_page_sign_in_as_public_body_and_submit()
    visit new_user_session_path
  	fill_in 'user_email', with: 'pb_ut@example.org'
  	fill_in 'user_password', with: 'Test1234'
  	click_button 'sign_in_button'
  end
end
World(SignInPage)
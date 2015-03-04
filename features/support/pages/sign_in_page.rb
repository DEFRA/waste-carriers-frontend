module SignInPage
  def sign_in_page_sign_in_as_public_body_and_submit()
    visit new_user_session_path
  	fill_in 'user_email', with: 'pb_ut@example.org'
  	fill_in 'user_password', with: my_password
  	click_button 'sign_in'
  end
  def sign_in_page_sign_in_as_environment_agency_user_and_submit()
    visit new_agency_user_session_path
  	expect(page).to have_text 'Sign in'
  	expect(page).to have_text 'Environment Agency login'
  	fill_in 'Email', with: my_agency_user.email
  	fill_in 'Password', with: my_agency_user.password
  	click_button 'sign_in'
  	page.has_content? 'agency-user-signed-in'
  end
  def sign_in_page_select_new_registration()
      RestClient.post Rails.configuration.waste_exemplar_services_admin_url + '/tasks/ir-repopulate', :content_type => :json, :accept => :json
      click_link 'new_registration'
  end
end
World(SignInPage)

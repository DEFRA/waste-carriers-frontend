module SearchPage
  def search_page_search(companyName: 'Find me in the public register')
  	sleep 5.0
  	visit public_path
    fill_in 'q', with: companyName
    click_button 'reg-search'
   end

  def search_page_check_search_result_positive
  	expect(page).to have_no_content('0 registrations found')
	end

  def search_page_check_search_result_negative
  	expect(page).to have_content('0 registrations found')
	end
end
World(SearchPage)
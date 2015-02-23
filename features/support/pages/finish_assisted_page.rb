module FinishAssistedPage
  def finish_assisted_page_check_registration_complete_text()
  page.should have_content 'Registration complete'
  page.should have_content 'has been registered as an upper tier waste carrier'

  # validate the access code is present and of the correct length
  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
    end

end
World(FinishAssistedPage)
module RelevantConvictionsPage
 
 	def relevant_convictions_page_select_no(submit: 'true')
  	choose 'registration_declaredConvictions_no'
  	relevant_convictions_page_submit_relevant_convictions_page if true
  	end

  	def relevant_convictions_page_select_yes(submit: 'true')
  	choose 'registration_declaredConvictions_yes'
  	relevant_convictions_page_submit_relevant_convictions_page if true
  	end
    
  	def relevant_convictions_page_submit_relevant_convictions_page()
    click_button 'continue'
  	end
end
World(RelevantConvictionsPage)
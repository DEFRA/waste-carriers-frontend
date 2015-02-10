module RelevantConvictionsPage
  def select_relevant_convictions_and_submit(value)
    choose(value)
    submit_relevant_convictions_page
  end

  def submit_relevant_convictions_page()
    click_button 'continue'
  end
end
World(RelevantConvictionsPage)
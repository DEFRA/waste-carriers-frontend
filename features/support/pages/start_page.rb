# Helper used in testing for working with the start page.
module StartPage
  def go_to_start_page
    visit start_path
  end

  def start_page_select(value)
    choose value
  end

  def start_page_submit
    click_button 'Next'
  end

  def start_page_select_and_submit(value)
    start_page_select value
    start_page_submit
  end
end
World(StartPage)

# Helper used in testing for working with the start page.
module StartPage
  def go_to_start_page
    visit start_path
  end

  def start_page_select_new
    choose 'new'
  end

  def start_page_select_renew
    choose 'renew'
  end

  def start_page_submit
    click_button 'next'
  end
end
World(StartPage)

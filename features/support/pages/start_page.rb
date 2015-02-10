# Helper used in testing for working with the start page.
module StartPage
  def go_to_start_page
    visit start_path
  end

  def start_page_select_new(submit: 'true')
    choose 'new'
    start_page_submit if submit
  end

  def start_page_select_renew(submit: 'true')
    choose 'renew'
    start_page_submit if submit
  end

  def start_page_submit
    click_button 'next'
  end
end
World(StartPage)

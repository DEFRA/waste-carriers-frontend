# Helper used in testing for working with the only deal with page.
module OnlyDealWithPage
  def go_to_only_deal_with_page
    visit only_deal_with_path
  end

  def only_deal_with_page_select(value)
    choose value
  end

  def only_deal_with_page_submit
    click_button 'Next'
  end

  def only_deal_with_page_select_and_submit(value)
    only_deal_with_page_select value
    only_deal_with_page_submit
  end
end
World(OnlyDealWithPage)

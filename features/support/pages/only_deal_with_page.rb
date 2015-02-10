# Helper used in testing for working with the only deal with page.
module OnlyDealWithPage
  def go_to_only_deal_with_page
    visit only_deal_with_path
  end

  def only_deal_with_page_select_no
    choose 'registration_onlyAMF_no'
  end

  def only_deal_with_page_select_yes
    choose 'registration_onlyAMF_yes'
  end

  def only_deal_with_page_submit
    click_button 'next'
  end
end
World(OnlyDealWithPage)

# Helper used in testing for working with the only deal with page.
module OnlyDealWithPage
  def go_to_only_deal_with_page
    visit only_deal_with_path
  end

  def only_deal_with_page?
    expect(page).to have_css 'div[data-journey$="onlydealwith"]'
  end

  def only_deal_with_page_select_no(submit: 'true')
    choose 'registration_onlyAMF_no'
    only_deal_with_page_submit if submit
  end

  def only_deal_with_page_select_yes(submit: 'true')
    choose 'registration_onlyAMF_yes'
    only_deal_with_page_submit if submit
  end

  def only_deal_with_page_submit
    click_button 'continue'
  end
end
World(OnlyDealWithPage)

# Helper used in testing for working with the finish assisted page.
module FinishAssistedPage
  def finish_assisted_page_check_registration_complete_text
    expect(page).to have_text 'Registration complete'
    expect(page).to have_text 'has been registered as an upper tier waste '\
                              'carrier'
  end

  def finish_assisted_page_check_pending_convictions_text
    expect(page).to have_text 'Registration pending'
    expect(page).to have_text 'The applicant declared relevant people with '\
                              'convictions so these will need to be cross '\
                              'checked before the registration can be completed'
  end

  def finish_assisted_page_check_pending_payment_text
    expect(page).to have_text 'Pay the registration charge'
  end

  def finish_assisted_page_check_charge_amount(amount:'105.00')
    total = find(
      :xpath,
      '//*[@id="payment-table-wrapper"]/table[1]/tbody/tr[2]/td[2]'
    ).text
    expect(total).to have_text "#{amount}"
  end
end
World(FinishAssistedPage)

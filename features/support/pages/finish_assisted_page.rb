# Helper used in testing for working with the finish assisted page.
module FinishAssistedPage
  def finish_assisted_page_check_registration_complete_text
    expect(page).to have_text 'Registration complete'
    expect(page).to have_text 'has been registered as an upper tier waste '\
                              'carrier'

    # validate the access code is present and of the correct length
    access_code = page.find_by_id 'accessCode'
    expect(access_code.text.length).to eq(6)
  end

  def finish_assisted_page_check_pending_convictions_text
    expect(page).to have_text 'Registration pending'
    expect(page).to have_text 'The applicant declared relevant people with '\
                              'convictions so these will need to be cross '\
                              'checked before the registration can be completed'

    # validate the access code is present and of the correct length
    access_code = page.find_by_id 'accessCode'
    expect(access_code.text.length).to eq(6)
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

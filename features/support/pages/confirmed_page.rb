# Helper used in testing for working with the confirmed page.
module ComfirmedPage
  def confirmed_page_finish_registration
    click_button 'finished'
  end

  def confirmed_page_check_text_registration_complete
    expect(page).to have_text 'Registration complete'
  end

  def confirmed_page_check_pending_convictions_text
    expect(page).to have_text 'Application received'
  end

  def confirmed_page_check_pending_payment_text
    expect(page).to have_text 'pay the registration charge'
  end

  def confirmed_page_check_charge_amount(amount:'105.00')
    total = find(
      :xpath,
      '//*[@id="payment-table-wrapper"]/table[1]/tbody/tr[2]/td[2]'
    ).text
    expect(total).to have_text "#{amount}"
  end
end
World(ComfirmedPage)

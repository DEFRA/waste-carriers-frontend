module PaymentsHelper

  # This is shown in the enter payment view and payment status view
  def amountSummary_for(model, includeBalance)
    if model.financeDetails.balance > 0
      if includeBalance
        t('registrations.form.balanceDue_text') + ' ' + number_to_currency(model.financeDetails.balance, :unit => "£")
      else
        t('registrations.form.balanceDue_text')
      end
    elsif model.financeDetails.balance < 0
      if includeBalance
        t('registrations.form.overpaid_text') + ' ' + number_to_currency(model.financeDetails.balance.abs, :unit => "£")
      else
        t('registrations.form.overpaid_text')
      end
    elsif model.financeDetails.balance == 0
      t('registrations.form.paidInFull_text')
    end
  end

  # This is shown in the payment status view, the difference to amountSummary_for is it has awaiting payment text instead of balance due text
  def amountPaymentSummary_for(model)
    if model.financeDetails.balance > 0
      t('registrations.form.awaitingPayment_text') + ' ' + number_to_currency(model.financeDetails.balance, :unit => "£")
    elsif model.financeDetails.balance < 0
      t('registrations.form.overpaid_text') + ' ' + number_to_currency(model.financeDetails.balance.abs, :unit => "£")
    elsif model.financeDetails.balance == 0
      t('registrations.form.paidInFull_text')
    end
  end

end

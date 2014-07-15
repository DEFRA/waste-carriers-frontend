module PaymentsHelper

  def pence_to_currency pence
    Money.new(pence).format
  end

  # This is shown in the enter payment view and payment status view
  def amountSummary_for(model, includeBalance)
    balance = model.financeDetails.balance

    prefix = if balance > 0
               t('registrations.form.awaitingPayment_text')
             elsif balance < 0
               t('registrations.form.overpaid_text')
             else
               t('registrations.form.paidInFull_text')
             end

    suffix = " #{pence_to_currency balance.abs}" unless balance.zero?
    includeBalance ? "#{prefix}#{suffix}" : prefix
  end

  # This is shown in the payment status view, the difference to amountSummary_for is it has awaiting payment text instead of balance due text
  def amountPaymentSummary_for(model)
    amountSummary_for model, true
  end

end

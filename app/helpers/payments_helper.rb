module PaymentsHelper

  # This is shown in the payment status view, the difference to amountSummary_for is it has awaiting payment text instead of balance due text
  def amount_payment_summary_for model
    amount_summary_for model, true
  end

  # This is shown in the enter payment view and payment status view
  def amount_summary_for model, include_balance
    balance = (model.finance_details.size > 0 ? model.finance_details.first.balance : 0)
    prefix = if balance.to_f  > 0
               t 'registrations.form.awaitingPayment_text'
             elsif balance.to_f  < 0
               t 'registrations.form.overpaid_text'
             else
               t 'registrations.form.paidInFull_text'
             end

    suffix = "#{pence_to_currency balance.to_f.abs}" unless balance.to_f == 0
    (include_balance and balance.to_f  != 0) ? raw("#{prefix} <span id=\"amountDue\">#{suffix}</span>") : prefix
  end

  def pence_to_currency pence
    Money.new(pence).format
  end

  def money_value_without_currency_symbol_and_without_pence_part_if_it_only_contains_zeroes pence
    humanized_money Money.new pence
  end
end

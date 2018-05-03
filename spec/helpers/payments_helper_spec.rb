require 'spec_helper'

describe PaymentsHelper do

  describe 'money parsing' do
    specify { expect(Monetize.parse('£100')).to be_a(Money) }
    specify { expect(Monetize.parse('£99').cents).to eq(9900) }
    specify { expect(Monetize.parse('£9.99').cents).to eq(999) }
  end

  describe '#pence_to_currency' do
    specify { expect(helper.pence_to_currency(15400)).to eq('£154.00') }
    specify { expect(helper.pence_to_currency(15900)).to eq('£159.00') }
  end

  describe '#money_value_without_currency_symbol_and_without_pence_part_if_it_only_contains_zeroes' do
    specify { expect(helper.money_value_without_currency_symbol_and_without_pence_part_if_it_only_contains_zeroes(15400)).to eq('154') }
    specify { expect(helper.money_value_without_currency_symbol_and_without_pence_part_if_it_only_contains_zeroes(15450)).to eq('154.50') }
  end

  describe '#amountPaymentSummary_for' do
    let(:registration) { Registration.create }
    let(:finance_details) { double 'finance_details' }
    let(:finance_details_array) { double 'finance_details_array' }

    before do
      allow(registration).to receive(:finance_details).and_return(finance_details_array)
      allow(finance_details_array).to receive(:size).and_return(1)
      allow(finance_details_array).to receive(:first).and_return(finance_details)
    end

    context 'positive balance' do
      before do
        allow(finance_details).to receive(:balance).and_return(10000)
      end

      specify { expect(helper.amount_payment_summary_for(registration)).to include('Awaiting payment') }
      specify { expect(helper.amount_payment_summary_for(registration)).to include('£100.00') }
    end

    context 'negative balance' do
      before do
        allow(finance_details).to receive(:balance).and_return(-10000)
      end

      specify { expect(helper.amount_payment_summary_for(registration)).to include('Overpaid by') }
      specify { expect(helper.amount_payment_summary_for(registration)).to include ('£100.00') }
    end

    context 'zero balance' do
      before do
        allow(finance_details).to receive(:balance).and_return(0)
      end

      specify { expect(helper.amount_payment_summary_for(registration)).to eq('Paid in full') }
    end
  end

  describe '#amountSummary_for' do
    let(:registration) { Registration.create }
    let(:finance_details) { double 'finance_details' }
    let(:finance_details_array) { double 'finance_details_array' }

    before do
      allow(registration).to receive(:finance_details).and_return(finance_details_array)
      allow(finance_details_array).to receive(:size).and_return(1)
      allow(finance_details_array).to receive(:first).and_return(finance_details)
    end

    context 'include balance' do
      context 'positive balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(10000)
        end

        specify { expect(helper.amount_summary_for(registration, true)).to include('Awaiting payment') }
        specify { expect(helper.amount_summary_for(registration, true)).to include('£100.00') }
      end

      context 'negative balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(-10000)
        end

        specify { expect(helper.amount_summary_for(registration, true)).to include('Overpaid by') }
        specify { expect(helper.amount_summary_for(registration, true)).to include('£100.00') }
      end

      context 'zero balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(0)
        end

        specify { expect(helper.amount_summary_for(registration, true)).to eq('Paid in full') }
      end
    end

    context 'exclude balance' do
      context 'positive balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(10000)
        end

        specify { expect(helper.amount_summary_for(registration, false)).to eq('Awaiting payment') }
      end

      context 'negative balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(-10000)
        end

        specify { expect(helper.amount_summary_for(registration, false)).to eq('Overpaid by') }
      end

      context 'zero balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(0)
        end

        specify { expect(helper.amount_summary_for(registration, false)).to eq('Paid in full') }
      end
    end
  end
end

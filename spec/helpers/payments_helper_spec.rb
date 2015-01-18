require 'spec_helper'

describe PaymentsHelper do

  describe 'money parsing' do
    specify { Monetize.parse('£100').should be_a Money }
    specify { Monetize.parse('£99').cents.should == 9900 }
    specify { Monetize.parse('£9.99').cents.should == 999 }
  end

  describe '#pence_to_currency' do
    specify { helper.pence_to_currency(15400).should == '£154.00' }
    specify { helper.pence_to_currency(15900).should == '£159.00' }
  end

  describe '#money_value_without_currency_symbol_and_without_pence_part_if_it_only_contains_zeroes' do
    specify { helper.money_value_without_currency_symbol_and_without_pence_part_if_it_only_contains_zeroes(15400).should == '154' }
    specify { helper.money_value_without_currency_symbol_and_without_pence_part_if_it_only_contains_zeroes(15450).should == '154.50' }
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

      specify { helper.amount_payment_summary_for(registration).should include 'Awaiting payment' }
      specify { helper.amount_payment_summary_for(registration).should include '£100.00' }
    end

    context 'negative balance' do
      before do
        allow(finance_details).to receive(:balance).and_return(-10000)
      end

      specify { helper.amount_payment_summary_for(registration).should include 'Overpaid by' }
      specify { helper.amount_payment_summary_for(registration).should include '£100.00' }
    end

    context 'zero balance' do
      before do
        allow(finance_details).to receive(:balance).and_return(0)
      end

      specify { helper.amount_payment_summary_for(registration).should == 'Paid in full' }
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

        specify { helper.amount_summary_for(registration, true).should include 'Awaiting payment' }
        specify { helper.amount_summary_for(registration, true).should include '£100.00' }
      end

      context 'negative balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(-10000)
        end

        specify { helper.amount_summary_for(registration, true).should include 'Overpaid by' }
        specify { helper.amount_summary_for(registration, true).should include '£100.00' }
      end

      context 'zero balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(0)
        end

        specify { helper.amount_summary_for(registration, true).should == 'Paid in full' }
      end
    end

    context 'exclude balance' do
      context 'positive balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(10000)
        end

        specify { helper.amount_summary_for(registration, false).should == 'Awaiting payment' }
      end

      context 'negative balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(-10000)
        end

        specify { helper.amount_summary_for(registration, false).should == 'Overpaid by' }
      end

      context 'zero balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(0)
        end

        specify { helper.amount_summary_for(registration, false).should == 'Paid in full' }
      end
    end
  end
end
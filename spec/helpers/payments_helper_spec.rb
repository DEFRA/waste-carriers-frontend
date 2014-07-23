require 'spec_helper'

describe PaymentsHelper do
  describe '#pence_to_currency' do
    specify { helper.pence_to_currency(15400).should == '£154.00' }
    specify { helper.pence_to_currency(15900).should == '£159.00' }
  end

  describe '#amountPaymentSummary_for' do
    let(:registration) { Registration.create }
    let(:finance_details) { double 'finance_details' }
    let(:finance_details_array) { double 'finance_details_array' }

    before do
      allow(registration).to receive(:finance_details).and_return(finance_details_array)
      allow(finance_details_array).to receive(:first).and_return(finance_details)
    end

    context 'positive balance' do
      before do
        allow(finance_details).to receive(:balance).and_return(10000)
      end

      specify { helper.amount_payment_summary_for(registration).should == 'Awaiting payment £100.00' }
    end

    context 'negative balance' do
      before do
        allow(finance_details).to receive(:balance).and_return(-10000)
      end

      specify { helper.amount_payment_summary_for(registration).should == 'Overpaid by £100.00' }
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
      allow(finance_details_array).to receive(:first).and_return(finance_details)
    end

    context 'include balance' do
      context 'positive balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(10000)
        end

        specify { helper.amount_summary_for(registration, true).should == 'Awaiting payment £100.00' }
      end

      context 'negative balance' do
        before do
          allow(finance_details).to receive(:balance).and_return(-10000)
        end

        specify { helper.amount_summary_for(registration, true).should == 'Overpaid by £100.00' }
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

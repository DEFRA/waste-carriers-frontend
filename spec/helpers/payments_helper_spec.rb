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

  describe '#amountPaymentSummary_for' do
    let(:registration) { Registration.new }
    let(:finance_details) { double 'finance_details' }

    before do
      allow(registration).to receive(:financeDetails).and_return(finance_details)
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
    let(:registration) { Registration.new }
    let(:finance_details) { double 'finance_details' }

    before do
      allow(registration).to receive(:financeDetails).and_return(finance_details)
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
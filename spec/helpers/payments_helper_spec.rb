require 'spec_helper'

describe PaymentsHelper do
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

      specify { helper.amountPaymentSummary_for(registration).should == 'Awaiting payment £100.00' }
    end

    context 'negative balance' do
      before do
        allow(finance_details).to receive(:balance).and_return(-10000)
      end

      specify { helper.amountPaymentSummary_for(registration).should == 'Overpaid by £100.00' }
    end

    context 'zero balance' do
      before do
        allow(finance_details).to receive(:balance).and_return(0)
      end

      specify { helper.amountPaymentSummary_for(registration).should == 'Paid in full' }
    end
  end
end
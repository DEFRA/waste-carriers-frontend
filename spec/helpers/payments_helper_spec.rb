require 'spec_helper'

describe PaymentsHelper do
  describe '#pence_to_currency' do
    specify { helper.pence_to_currency(15400).should == '£154.00' }
    specify { helper.pence_to_currency(15900).should == '£159.00' }
  end
end
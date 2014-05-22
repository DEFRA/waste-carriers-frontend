require 'spec_helper'

describe Registration do
  context 'businesstype step' do
    subject { Registration.new(current_step: 'businesstype') }

    # TODO need to put validation back in after show-and-tell

    xit { should validate_presence_of(:businessType).with_message(/must be completed/) }
    xit { should allow_value('soleTrader', 'partnership', 'limitedCompany', 'publicBody', 'charity', 'collectionAuthority', 'disposalAuthority', 'regulationAuthority', 'other').for(:businessType) }
    xit { should_not allow_value('sole_trader', 'plc').for(:businessType) }
  end
end
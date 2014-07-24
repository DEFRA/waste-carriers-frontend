require 'spec_helper'

describe ConvictionsCaller do
  describe '#url' do
    context 'individual search' do
      subject { ConvictionsCaller.new first_name: 'Barry', last_name: 'Butler', date_of_birth: '1970-01-01' }

      its(:url) { should == 'http://localhost/individual_convictions?first_name="Barry"&last_name="Butler"&date_of_birth="1970-01-01"' }
    end
  end
end
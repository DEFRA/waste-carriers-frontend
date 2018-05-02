require 'spec_helper'

describe KeyPeopleHelper do
  describe '#first_name_last_name' do
    specify { expect(helper.first_name_last_name(KeyPerson.new(first_name: 'Barry', last_name: 'Butler'))).to eq('Barry Butler') }
    specify { expect(helper.first_name_last_name(KeyPerson.new(first_name: 'Ron Jon', last_name: 'Paul'))).to eq('Ron Jon Paul') }
  end
end

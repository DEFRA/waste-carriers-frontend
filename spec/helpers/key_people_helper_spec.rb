require 'spec_helper'

describe KeyPeopleHelper do
  describe '#first_name_last_name' do
    specify { helper.first_name_last_name(KeyPerson.new(first_name: 'Barry', last_name: 'Butler') ).should == 'Barry Butler' }
    specify { helper.first_name_last_name(KeyPerson.new(first_name: 'Ron Jon', last_name: 'Paul') ).should == 'Ron Jon Paul' }
  end
end
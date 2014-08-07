require 'spec_helper'

describe KeyPeopleHelper do
  describe '#first_name_last_name' do
    specify { helper.first_name_last_name(KeyPerson.new(first_name: 'Barry', last_name: 'Butler') ).should == 'Barry Butler' }
    specify { helper.first_name_last_name(KeyPerson.new(first_name: 'Ron Jon', last_name: 'Paul') ).should == 'Ron Jon Paul' }
  end

  describe '#contains_relevant_people?' do
    let(:relevant_person) { KeyPerson.new(first_name: 'Barry', last_name: 'Butler', person_type: 'RELEVANT') }
    let(:irrelevant_person) { KeyPerson.new(first_name: 'Henry', last_name: 'Brown') }

    specify { helper.contains_relevant_people?([]).should be_false }
    specify { helper.contains_relevant_people?([relevant_person]).should be_true }
    specify { helper.contains_relevant_people?([irrelevant_person]).should be_false }
    specify { helper.contains_relevant_people?([relevant_person, irrelevant_person]).should be_true }
    specify { helper.contains_relevant_people?([irrelevant_person, relevant_person]).should be_true }
  end
end
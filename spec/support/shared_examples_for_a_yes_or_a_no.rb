shared_examples_for 'a yes or a no' do |attribute_symbol|
  it { should validate_presence_of(attribute_symbol).with_message(/You must answer this question/) }
  it { should allow_value('yes', 'no').for(attribute_symbol) }
  it { should_not allow_value('y', 'n').for(attribute_symbol) }
end
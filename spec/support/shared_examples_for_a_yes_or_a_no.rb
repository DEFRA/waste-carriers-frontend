shared_examples_for 'a yes or a no' do |attribute_symbol|
  it { is_expected.to validate_presence_of(attribute_symbol).with_message(/You must answer this question/) }
  it { is_expected.to allow_value('yes', 'no').for(attribute_symbol) }
  it { is_expected.not_to allow_value('y', 'n').for(attribute_symbol) }
end

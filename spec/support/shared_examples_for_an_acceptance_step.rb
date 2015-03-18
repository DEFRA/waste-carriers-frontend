shared_examples_for 'an acceptance step' do
  it { should validate_acceptance_of(:declaration).with_message(/Please confirm the/) }
end
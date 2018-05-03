shared_examples_for 'a company name step' do
  it { is_expected.to validate_presence_of(:companyName).with_message(/You must enter/) }
  it { is_expected.to allow_value('Dun & Bradstreet', '37signals', "Barry's Bikes").for(:companyName) }
  it { is_expected.not_to allow_value('<script>alert("hi");</script>').for(:companyName) }
  it { is_expected.to allow_value('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .-&\'’[],()').for(:companyName) }
  it { is_expected.to validate_length_of(:companyName).is_at_most(150) }
end

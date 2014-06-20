shared_examples_for 'a company name step' do
  it { should validate_presence_of(:companyName).with_message(/must be completed/) }
  it { should allow_value('Dun & Bradstreet', '37signals', "Barry's Bikes").for(:companyName) }
  it { should_not allow_value('<script>alert("hi");</script>').for(:companyName) }
  it { should ensure_length_of(:companyName).is_at_most(70) }
end
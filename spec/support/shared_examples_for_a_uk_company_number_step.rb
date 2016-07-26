shared_examples_for 'a uk company number step' do
  it 'is a uk limited company' do
    expect(subject.uk_limited_company?).to eq(true)
    expect(subject.foreign_limited_company?).to eq(false)
  end

  it { should validate_presence_of(:company_no).with_message(/You must enter/) }

  it 'should not allow company which is not active', :vcr do
    subject.should_not allow_value('05868270').for(:company_no)
  end

  it 'should allow active company', :vcr do
    subject.should allow_value('02050399').for(:company_no)
  end

  context 'check format only' do
    before do
      allow_any_instance_of(CompaniesHouseCaller).to receive(:status).and_return(:active)
    end

    it { should allow_value('06731292', '6731292', '07589628', '7589628', '00000001',
      '1', 'ni123456', 'NI123456', 'RO123456', 'SC123456', 'OC123456', 'SO123456',
      'NC123456', 'AC097609').for(:company_no) }

    it { should_not allow_value('NII12345', 'NI1234567', '123456789', '0', '00000000',
      '-12345678', '-1234567').for(:company_no) }
  end
end

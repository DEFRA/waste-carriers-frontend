shared_examples_for 'a physical address step' do
  context 'manual-uk addressMode' do
    before { subject.addressMode = 'manual-uk' }

    describe 'presence' do
      it { should validate_presence_of(:houseNumber).with_message(/must be completed/) }
      it { should validate_presence_of(:streetLine1).with_message(/must be completed/) }
      it { should_not validate_presence_of(:streetLine2).with_message(/must be completed/) }
      it { should validate_presence_of(:townCity).with_message(/must be completed/) }
      it { should validate_presence_of(:postcode).with_message(/must be completed/) }
    end

    describe 'format' do
      it { should allow_value('1', '1a', 'Cloud-Base', "Lockeeper's Cottage").for(:houseNumber) }
      it { should_not allow_value('£2').for(:houseNumber).with_message(/can only contain letters, spaces, numbers and hyphens and be no longer than 35 characters/) }
      it { should allow_value('Bristol', 'Newcastle-upon-Type', 'Leamington Spa', "Gerrard's Cross").for(:townCity)}
      it { should_not allow_value('Bristol!', 'District 9').for(:townCity) }
      it { should allow_value('BS1 5AH', 'BS22 5AH').for(:postcode) }
      it { should_not allow_value('1234', 'blah').for(:postcode) }
    end

    describe 'length' do
      it { should ensure_length_of(:houseNumber).is_at_most(35) }
      it { should ensure_length_of(:streetLine1).is_at_most(35) }
      it { should ensure_length_of(:streetLine2).is_at_most(35) }
    end
  end

  context 'manual-foreign addressMode' do
    before { subject.addressMode = 'manual-foreign' }

    describe 'presence' do
      it { should validate_presence_of(:streetLine1).with_message(/must be completed/) }
      it { should_not validate_presence_of(:streetLine2).with_message(/must be completed/) }
      it { should_not validate_presence_of(:streetLine3) }
      it { should_not validate_presence_of(:streetLine4) }
      it { should validate_presence_of(:country).with_message(/must be completed/) }
    end

    describe 'length' do
      it { should ensure_length_of(:streetLine1).is_at_most(35) }
      it { should ensure_length_of(:streetLine2).is_at_most(35) }
      it { should ensure_length_of(:streetLine3).is_at_most(35) }
      it { should ensure_length_of(:streetLine4).is_at_most(35) }
      it { should ensure_length_of(:country).is_at_most(35) }
    end
  end
end
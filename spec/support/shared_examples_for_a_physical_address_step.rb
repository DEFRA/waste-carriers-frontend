shared_examples_for 'a physical address step' do
  context 'no addressMode' do
    before { subject.addressMode = nil }

    it_behaves_like 'a uk address'
  end

  context 'manual-uk addressMode' do
    before { subject.addressMode = 'manual-uk' }

    it_behaves_like 'a uk address'
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
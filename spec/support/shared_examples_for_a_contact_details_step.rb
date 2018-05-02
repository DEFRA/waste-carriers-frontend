shared_examples_for 'a contact details step' do
  describe 'presence' do
    it { is_expected.to validate_presence_of(:firstName).with_message(/You must enter/) }
    it { is_expected.to validate_presence_of(:lastName).with_message(/You must enter/) }
    it { is_expected.not_to validate_presence_of(:position).with_message(/must be completed/) }
    it { is_expected.to validate_presence_of(:phoneNumber).with_message(/You must enter/) }
  end

  describe 'format' do
    subject { Registration.ctor(firstName: 'Barry', position: 'Pub landlord', lastName: 'Butler', phoneNumber: '999', contactEmail: 'barry@butler.com' ) }

    it { is_expected.to allow_value('John', 'John-Paul', 'Sally Ann', "T'pau").for(:firstName) }
    it { is_expected.not_to allow_value('Johnnie5', 'K.R.S One').for(:firstName) }
    it { is_expected.to validate_length_of(:firstName).is_at_most(35) }

    it { is_expected.to allow_value('Butler', 'Foster-Jones', 'McTavish', 'Mc Hale', "O'Brien").for(:lastName) }
    it { is_expected.not_to allow_value('1').for(:lastName) }
    it { is_expected.to validate_length_of(:lastName).is_at_most(35) }

    it { is_expected.to allow_value('', 'Foreman', 'Ruby Dev', 'Change-manager').for(:position) }
    it { is_expected.not_to allow_value('Big Guy 1', 'Employee #1').for(:position) }

    it { is_expected.to allow_value('0117 9109099', '(0)117 9109099', '+44 (0)117 9109099', '+44 (0)117 91-09099').for(:phoneNumber) }
    it { is_expected.not_to allow_value('999', 'my landline', 'home').for(:phoneNumber) }
    it { is_expected.to validate_length_of(:phoneNumber).is_at_most(20) }

    context 'digital route' do
      before { subject.metaData.first.route = 'DIGITAL' }

      it_behaves_like 'email validation', :contactEmail
    end

    context 'assisted digital route' do
      before { subject.metaData.first.route = 'ASSISTED_DIGITAL' }

      it { is_expected.not_to validate_presence_of(:contactEmail) }
    end
  end
end

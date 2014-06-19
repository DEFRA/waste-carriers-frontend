shared_examples_for 'a contact details step' do
  describe 'presence' do
    it { should validate_presence_of(:firstName).with_message(/must be completed/) }
    it { should validate_presence_of(:lastName).with_message(/must be completed/) }
    it { should validate_presence_of(:position).with_message(/must be completed/) }
    it { should validate_presence_of(:phoneNumber).with_message(/must be completed/) }
  end

  describe 'format' do
    subject { Registration.new(firstName: 'Barry', position: 'Pub landlord', lastName: 'Butler', phoneNumber: '999', contactEmail: 'barry@butler.com' ) }

    it { should allow_value('John', 'John-Paul', 'Sally Ann', "T'pau").for(:firstName) }
    it { should_not allow_value('Johnnie5', 'K.R.S One').for(:firstName) }
    it { should ensure_length_of(:firstName).is_at_most(35) }

    it { should allow_value('Butler', 'Foster-Jones', 'McTavish', 'Mc Hale', "O'Brien").for(:lastName) }
    it { should_not allow_value('1').for(:lastName) }
    it { should ensure_length_of(:lastName).is_at_most(35) }

    it { should allow_value('Foreman', 'Ruby Dev', 'Change-manager').for(:position) }
    it { should_not allow_value('Big Guy 1', 'Employee #1').for(:position) }

    it { should allow_value('0117 9109099', '(0)117 9109099', '+44 (0)117 9109099', '+44 (0)117 91-09099').for(:phoneNumber) }
    it { should_not allow_value('999', 'my landline', 'home').for(:phoneNumber) }
    it { should ensure_length_of(:phoneNumber).is_at_most(20) }

    context 'digital route' do
      before { subject.routeName = 'DIGITAL' }

      it_behaves_like 'email validation', :contactEmail
    end

    context 'assisted digital route' do
      before { subject.routeName = 'ASSISTED_DIGITAL' }

      it { should_not validate_presence_of(:contactEmail) }
    end
  end
end
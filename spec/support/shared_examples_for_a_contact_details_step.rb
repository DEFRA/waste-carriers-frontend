VALID_EMAIL_ADDRESSES = ['user@foo.COM', 'A_US-ER@f.b.org', 'frst.lst@foo.jp', 'a+b@baz.cn']
INVALID_EMAIL_ADDRESSES = ['barry@butler@foo.com' 'user@foo,com', 'user_at_foo.org', 'example.user@foo.', 'foo@bar_baz.com', 'foo@bar+baz.com']

VALID_TELEPHONE_NUMBERS = ['0117 9109099', '(0)117 9109099', '+44 (0)117 9109099', '+44 (0)117 91-09099']
INVALID_TELEPHONE_NUMBERS = ['999', 'my landline', 'home']

VALID_JOB_TITLES = ['Foreman', 'Ruby Dev', 'Change-manager']
INVALID_JOB_TITLES = ['Big Guy 1', 'Employee #1']

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

    it { should allow_value(*VALID_JOB_TITLES).for(:position) }
    it { should_not allow_value(*INVALID_JOB_TITLES).for(:position) }

    it { should allow_value(*VALID_TELEPHONE_NUMBERS).for(:phoneNumber) }
    it { should_not allow_value(*INVALID_TELEPHONE_NUMBERS).for(:phoneNumber) }
    it { should ensure_length_of(:phoneNumber).is_at_most(20) }

    context 'digital route' do
      before { subject.routeName = 'DIGITAL' }

      it { should validate_presence_of(:contactEmail).with_message(/must be completed/) }

      it { should allow_value(*VALID_EMAIL_ADDRESSES).for(:contactEmail) }
      it { should_not allow_value(*INVALID_EMAIL_ADDRESSES).for(:contactEmail) }
    end

    context 'assisted digital route' do
      before { subject.routeName = 'ASSISTED_DIGITAL' }

      it { should_not validate_presence_of(:contactEmail) }
    end
  end
end
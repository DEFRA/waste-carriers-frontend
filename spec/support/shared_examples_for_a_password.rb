shared_examples_for 'password with strength restrictions' do
  xit "waiting for validation messages completion for all sections" do
    is_expected.to validate_presence_of(:password).with_message(/You must create a password/)
  end

  xit "waiting for validation messages completion for all sections" do
    is_expected.to validate_confirmation_of(:password).with_message(/You must confirm your password/)
  end

  # Valid passwords must contain lowercase, uppercase and numeric characters.
  # Symbols are also allowed, but not required.
  it { is_expected.to allow_value('myPass145').for(:password) }
  it { is_expected.to allow_value('myPass1$!.#@£').for(:password) }

  # Valid passwords must contain at least one lowercase, uppercase and numeric character.
  it { is_expected.not_to allow_value('751836492').for(:password) }   # Only numbers
  it { is_expected.not_to allow_value('bdohldnkd').for(:password) }   # Only lowercase
  it { is_expected.not_to allow_value('UDMGLWBOD').for(:password) }   # Only uppercase
  it { is_expected.not_to allow_value('tjst13848').for(:password) }   # No uppercase
  it { is_expected.not_to allow_value('16KEWN8JQ').for(:password) }   # No lowercase
  it { is_expected.not_to allow_value('iflIEJMkf').for(:password) }   # No numbers

  # Valid passwords must be between 8 and 128 characters.
  xit "waiting for validation messages completion for all sections" do
    is_expected.to validate_length_of(:password).is_at_least(8).with_message(/You must create a valid password/).is_at_most(128).with_message(/You must create a valid password/)
  end
end

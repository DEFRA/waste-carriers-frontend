shared_examples_for 'password with strength restrictions' do
  it { should validate_presence_of(:password).with_message(/must be completed/) }
  it { should validate_confirmation_of(:password) }

  # Valid passwords must contain lowercase, uppercase and numeric characters.
  # Symbols are also allowed, but not required.
  it { should allow_value('myPass145').for(:password) }
  it { should allow_value('myPass1$!.#@£').for(:password) }
  
  # Valid passwords must contain at least one lowercase, uppercase and numeric character.
  it { should_not allow_value('751836492').for(:password) }   # Only numbers
  it { should_not allow_value('bdohldnkd').for(:password) }   # Only lowercase
  it { should_not allow_value('UDMGLWBOD').for(:password) }   # Only uppercase
  it { should_not allow_value('tjst13848').for(:password) }   # No uppercase
  it { should_not allow_value('16KEWN8JQ').for(:password) }   # No lowercase
  it { should_not allow_value('iflIEJMkf').for(:password) }   # No numbers

  # Valid passwords must be between 8 and 128 characters.
  it { should ensure_length_of(:password).is_at_least(8).is_at_most(128) }
end

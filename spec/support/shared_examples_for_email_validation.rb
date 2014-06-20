shared_examples_for 'email validation' do |attribute_symbol|
  it { should validate_presence_of(attribute_symbol).with_message(/must be completed/) }

  it { should allow_value('user@foo.COM', 'A_US-ER@f.b.org', 'frst.lst@foo.jp', 'a+b@baz.cn').for(attribute_symbol) }
  it { should_not allow_value('barry@butler@foo.com' 'user@foo,com', 'user_at_foo.org', 'example.user@foo.', 'foo@bar_baz.com', 'foo@bar+baz.com').for(attribute_symbol) }
end
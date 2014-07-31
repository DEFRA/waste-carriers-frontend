require 'spec_helper'

describe KeyPerson do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }

  it { should validate_presence_of(:dob_day) }
  it { should validate_presence_of(:dob_month) }
  it { should validate_presence_of(:dob_year) }
end
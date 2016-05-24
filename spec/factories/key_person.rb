FactoryGirl.define do
  factory :key_person do

    sequence(:id) { |n| n }
    first_name 'Thomas'
    last_name 'Smith'
    dob '1980-10-15'
    dob_year '1980'
    dob_month '10'
    dob_day '15'
  end
end

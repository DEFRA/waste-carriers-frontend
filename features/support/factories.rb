require 'factory_girl'

FactoryGirl.define do
  factory :admin do
    sequence(:email) { |n| "admin_#{n}@waste-exemplar.gov.uk" }
    password 'secret123'
  end
end
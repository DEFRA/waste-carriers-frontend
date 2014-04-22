require 'factory_girl'

FactoryGirl.define do
  factory :admin do
    sequence(:email) { |n| "admin_#{n}@waste-exemplar.gov.uk" }
    password 'secret123'
  end

  factory :agency_user do
    sequence(:email) { |n| "agency_user_#{n}@agency.gov.uk" }
    password 'secret123'
  end

  factory :user do
    sequence(:email) { |n| "joe_#{n}@example.com" }
    password 'secret123'
  end
end
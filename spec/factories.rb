require 'factory_girl'

FactoryGirl.define do
  factory :admin do
    sequence(:email) { |n| "admin_#{n}@waste-exemplar.gov.uk" }
    password 'secret123'
  end

  factory :agency_user do
    sequence(:email) { |n| "agency_user_#{n}@agency.gov.uk" }
    password 'secret123'

#
# This is a copy of the roles that assigned to a agency user
# Role_financeBasic
# Role_financeAdmin
# Role_ncccRefund
#
    trait :finance_admin do
      after(:create) { |user| user.add_role(:Role_financeAdmin) }
    end
    trait :finance_basic do
      after(:create) { |user| user.add_role(:Role_financeBasic) }
    end
    trait :ncccRefund do
      after(:create) { |user| user.add_role(:Role_ncccRefund) }
    end

    factory :finance_admin_user, traits: [:finance_admin]
    factory :finance_basic_user, traits: [:finance_basic]
    factory :agency_refund_user, traits: [:ncccRefund]
  end

  factory :user do
    sequence(:email) { |n| "joe_#{n}@example.com" }
    password 'secret123'
  end
end
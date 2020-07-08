# frozen_string_literal: true

FactoryGirl.define do
  factory :feature_toggle, class: FeatureToggle do
    key { "test-feature" }

    active { false }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end

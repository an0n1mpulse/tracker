# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    sequence(:mlid) { |n| " #{Faker::Lorem.characters(1)}#{n}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    dob { Faker::Time.between 20.years.ago, 10.years.ago }
    estimated_dob { Faker::Boolean.boolean 0.2 }
    gender { %w[male female].sample }
    organization
  end
end

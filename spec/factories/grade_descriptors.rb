# frozen_string_literal: true

FactoryBot.define do
  factory :grade_descriptor do
    sequence(:mark) { |n| n }
    grade_description { Faker::Hipster.sentence }
    skill { create :skill }
  end
end

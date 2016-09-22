FactoryGirl.define do
  factory :student do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    dob { Faker::Time.between 20.years.ago, 10.years.ago }
    estimated_dob { Faker::Boolean.boolean 0.2 }
    gender { Faker::Number.between 0, 1 }
    organization { create :organization }
  end
end
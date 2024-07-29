FactoryBot.define do
  factory :room do
    name { Faker::Lorem.unique.word }
    is_private { false }
  end
end
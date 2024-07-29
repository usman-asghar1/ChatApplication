FactoryBot.define do
  factory :participant do
    association :user
    association :room
  end
end

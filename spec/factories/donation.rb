FactoryBot.define do
  factory :donation do
    association :copy
    association :giver, factory: :user
    trait :donated do
      state 'donated'
    end
    trait :requested do
      state 'requested'
    end
    trait :locked do
      state 'locked'
    end
    factory :donated_donation, traits: [:donated]
    factory :requested_donation, traits: [:requested]
    factory :locked_donation, traits: [:locked]
  end
end
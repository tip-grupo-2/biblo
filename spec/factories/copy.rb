# frozen_string_literal: true

FactoryBot.define do
  factory :copy do
    user
    association :book
  end
end

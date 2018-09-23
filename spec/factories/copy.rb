# frozen_string_literal: true

FactoryBot.define do
  factory :copy do
    association :book
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'Jose Gomez' }
    address { 'Av Siempre Viva 234' }
    sequence(:email) { |n| "jose#{n}@gomez.com" }
    password { '12345678' }
  end
end

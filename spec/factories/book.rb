# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    isbn { '1230123456789' }
    title { 'Moby Dick' }
    author { 'Herman Melville' }
  end
end

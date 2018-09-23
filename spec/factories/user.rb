FactoryBot.define do
  factory :user do
    name {'Jose Gomez'}
    address {'Av Siempre Viva 234'}
    email { 'jose@gomez.com' }
    password { '12345678' }
  end
end
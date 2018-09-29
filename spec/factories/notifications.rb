FactoryBot.define do
  factory :notification do
    recipient_id 1
    requester_id 1
    copy_id 1
    read_at nil
    action "solicitado"
  end
end

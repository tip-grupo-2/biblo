FactoryBot.define do
  factory :notification do
    recipient_id 1
    requester_id 1
    copy_id 1
    read_at "2018-09-23 19:06:34"
    action "MyString"
  end
end

class Notification < ActiveRecord::Base
  belongs_to :recipient, class_name: User
  belongs_to :requester, class_name: User
  belongs_to :copy, class_name: Copy
  has_one :book_request
  validates_presence_of :recipient, :requester, :action

  def self.new_request_notification(requester, copy)
    Notification.new(requester_id: requester.id, recipient_id: copy.user_id, copy_id: copy.id, action: 'solicitado')
  end
end

class BookRequest < ActiveRecord::Base
  belongs_to :recipient, class_name: User
  belongs_to :requester, class_name: User
  belongs_to :copy, class_name: Copy
  has_many :notifications
end
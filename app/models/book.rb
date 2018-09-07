class Book < ActiveRecord::Base
  validates :isbn, uniqueness: true, length: {is: 13}, presence: true
  has_many :copies

end
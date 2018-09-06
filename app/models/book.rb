class Book < ActiveRecord::Base
  has_many :copies
end
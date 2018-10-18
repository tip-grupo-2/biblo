# frozen_string_literal: true

class Book < ActiveRecord::Base
  validates :isbn, uniqueness: true, presence: true
  has_many :copies
  has_one :user #dueño acutal

  ISBN_PROVIDER_ERROR = Class.new(StandardError)
  ISBN_LENGTH_ERROR = Class.new(StandardError)

end

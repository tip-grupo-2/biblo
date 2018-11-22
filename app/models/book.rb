# frozen_string_literal: true

class Book < ActiveRecord::Base
  validates :isbn, uniqueness: true
  has_many :copies
  has_one :user

  ISBN_PROVIDER_ERROR = Class.new(StandardError)
  ISBN_LENGTH_ERROR = Class.new(StandardError)

  def average_rate
    rates = Rate.where(:book_id => self.id).pluck(:amount)
    average = 0
    if rates.count > 0
      average = rates.sum / rates.count
    end

    average
  end
end

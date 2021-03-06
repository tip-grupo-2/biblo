# frozen_string_literal: true

class Copy < ActiveRecord::Base
  belongs_to :book
  belongs_to :user
  belongs_to :original_owner, class_name: User

  ALREADY_REQUESTED_ERROR = Class.new(StandardError)
  NOT_IN_POSSESSION_ERROR = Class.new(StandardError)
  REJECTED_STATE_ERROR = Class.new(StandardError)

  def current_owner(current_user)
    user_id == current_user.id
  end

  def last_rate_amount
    rate = Rate.where(:copy_id => self.id).order("created_at").last
    amount = 0
    unless(rate.nil?)
      amount = rate.amount
    end
    amount
  end
end

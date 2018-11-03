# frozen_string_literal: true

class Copy < ActiveRecord::Base
  belongs_to :book
  belongs_to :user
  belongs_to :original_owner, class_name: User

  ALREADY_REQUESTED_ERROR = Class.new(StandardError)
  NOT_IN_POSSESSION_ERROR = Class.new(StandardError)

  def current_and_original_owner(current_user)
    user_id == current_user.id && original_owner_id == current_user.id
  end
end

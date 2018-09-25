# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def notifications(user)
    Notification.where(recipient_id: user.id)
  end
  helper_method :notifications

end

class NotificationsController < ApplicationController


  def index
    notifications = Notification.where(recipient_id: params[:user]).order(:created_at).limit(10)
    render :json => generate_response(notifications)
  end

  private

  def notification_params
    params.permit(:user)
  end

  def generate_response(notifications)
    notifications.map do |notification|
      { requester: notification.requester.email, book_title: notification.copy.title, action: notification.action,
        read_at: notification.read_at }
    end
  end

end
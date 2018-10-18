class NotificationsController < ApplicationController
  before_filter :only_logged_users
  before_filter :only_recipient_user, :only => :show

  def index
    notifications = Notification.where(recipient_id: params[:user]).order(created_at: :desc).limit(10).reverse
    render :json => generate_response(notifications)
  end

  def mark_as_read
    notifications = Notification.where(id: params[:ids])
    ActiveRecord::Base.transaction do
      notifications.each do |notification|
        notification.read_at = DateTime.now
        notification.save!
      end
    end
    render json: { msg: 'Notificaciones marcadas como leidas.' }, status: 200
  rescue ActiveRecord::RecordInvalid
    flash[:notice] = 'Ocurrio un error al actualizar las notificaciones'
    render json: { msg: 'No se puede ejecutar la operacion.' }, status: 400
  end

  def show
    @notification = Notification.find(notification_params[:id])
  end

  def respond_request
    notification = Notification.find(notification_params[:id])
    update_book_and_request(notification_params[:choice], notification)
    notify_requester(notification_params[:message], notification)
  end

  private

  def notification_params
    params.permit(:user, :id, :choice, :message)
  end

  def generate_response(notifications)
    notifications.map do |notification|
      { id: notification.id, requester: notification.requester.name, book_title: notification.copy.book.title, action: notification.action,
        read_at: notification.read_at }
    end
  end

  def notify_requester(choice, notification)
    request = BookRequest.new(requester_id: notification.recipient_id, recipient_id: notification.requester_id,
                    copy_id: notification.copy.id, accepted: notification.book_request.accepted )
    Notification.create!(requester_id: notification.recipient_id, recipient_id: notification.requester_id, copy_id: notification.copy.id,
                         action: choice, book_request: request)
    flash[:success] = 'La solicitud fue contestada satisfactoriamente!'
    redirect_to root_path
  end

  def update_book_and_request(choice, notification)
    copy_request = notification.book_request
    copy = copy_request.copy
    ActiveRecord::Base.transaction do
      copy.update_attributes!(requested: choice) unless copy.requested?
      copy_request.update_attributes!(accepted: choice)
    end
  end

  def only_recipient_user
    redirect_to root_path unless Notification.find(notification_params[:id]).recipient_id == current_user.id
  end
end
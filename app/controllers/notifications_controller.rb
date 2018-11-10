class NotificationsController < ApplicationController
  before_filter :only_logged_users
  before_filter :only_recipient_or_requester_user, :only => :show

  def index
    notifications = Notification.where(recipient_id: params[:user]).order(created_at: :desc).limit(10).reverse
    render :json => generate_response(notifications)
  end

  def all_notifications
    notifications = Notification.where("recipient_id = ? or requester_id = ?", current_user.id, current_user.id)
    @notifications_as_recipient = notifications.select{|notification| notification.donation.giver == current_user}
    @notifications_as_requester = notifications.select{|notification| notification.donation.requester == current_user}
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
    update_book_and_request(notification_params[:choice], notification.donation)
    notify_requester(notification_params[:message], notification)
  end

  def confirm_delivery
    notification = Notification.find(notification_params[:id])
    confirm_book_delivery(notification.donation)
    notify_requester(notification_params[:message], notification)
  end

  def confirm_reception
    notification = Notification.find(notification_params[:id])
    confirm_book_reception(notification.donation)
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
    notification.update!(requester_id: notification.recipient_id,
                         recipient_id: notification.requester_id,
                         copy_id: notification.copy.id,
                         action: choice,
                         donation: notification.donation)
    flash[:success] = 'La solicitud fue contestada satisfactoriamente!'
    redirect_to :back
  end

  def update_book_and_request(choice, donation)
    ActiveRecord::Base.transaction do
      if choice == 'true' # :c
        donation.accept!
      else
        donation.reject!
      end
      donation.save
    end
  end

  def confirm_book_delivery(donation)
    ActiveRecord::Base.transaction do
      donation.confirm_delivery!
      exchange_possession(donation) if donation.finished?
      donation.save
    end
  end

  def confirm_book_reception(donation)
    ActiveRecord::Base.transaction do
      donation.confirm_reception!
      exchange_possession(donation) if donation.finished?
      donation.save
    end
  end

  def exchange_possession(donation)
    donation.requester.receive_donated_copy(donation.copy)
  end

  def only_recipient_or_requester_user
    redirect_to root_path unless Notification.find(notification_params[:id]).recipient_id == current_user.id || Notification.find(notification_params[:id]).requester_id == current_user.id
  end
end
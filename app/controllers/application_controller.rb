# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def user_avatar(user)
    user.avatar.present? ? user.avatar : 'default_avatar.png'
  end
  helper_method :user_avatar

  def only_logged_users
    redirect_to root_path unless user_signed_in?
  end

  def notification_status(request)
    case request.accepted
      when nil
        'aun no ha sido contestada.'
      when true
        'ha sido aceptada.'
      when false
        'ha sido rechazada.'
    end
  end
  helper_method :notification_status

  protected

  # method necessary for devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name address])
  end
end

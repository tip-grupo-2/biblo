# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # POST /resource
  def create
    if user_exists?
      flash[:notice] = 'Ya existe una cuenta asociada a esa direccion de e-mail'
      redirect_to :back
    else
      super
    end
  end

  private

  def user_exists?
    User.find_by(email: sign_up_params[:email]).present?
  end
end

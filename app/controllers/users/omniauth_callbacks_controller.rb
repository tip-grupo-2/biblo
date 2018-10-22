# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    authenticate_user
  end

  def google_oauth2
    authenticate_user
  end

  private

  def authenticate_user
    user = User.from_omniauth(request.env['omniauth.auth'])
    if user.persisted?
      flash[:info] = 'Bienvenido/a!'
      sign_in_and_redirect user
    else
      session['devise.user_attributes'] = user.attributes
      redirect_to new_user_registration_url
    end
  end
end

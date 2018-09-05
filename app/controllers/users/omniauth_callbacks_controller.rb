# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

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
      flash.notice = 'Bienvenido/a!'
      sign_in_and_redirect user
    else
      session['devise.user_attributes'] = user.attributes
      redirect_to new_user_registration_url
    end
  end
end

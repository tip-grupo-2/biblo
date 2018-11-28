# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_filter :redirect_if_address_nil, :except => [:sign_out]
  def show
  end
end

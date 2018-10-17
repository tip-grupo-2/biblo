# frozen_string_literal: true

class BibliotecaController < ApplicationController
  def show
    if current_user && current_user.address.empty?
      redirect_to edit_user_path(current_user) and return
    end
    render template: "biblioteca/#{params[:page]}" and return
  end
end

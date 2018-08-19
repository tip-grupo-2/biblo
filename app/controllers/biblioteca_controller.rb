class BibliotecaController < ApplicationController
  def show
    render template: "biblioteca/#{params[:page]}"
  end
end

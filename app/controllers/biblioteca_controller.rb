# frozen_string_literal: true

class BibliotecaController < ApplicationController
  def show
    render template: "biblioteca/#{params[:page]}"
  end
end

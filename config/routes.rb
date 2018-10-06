# frozen_string_literal: true

Rails.application.routes.draw do
  get '/biblioteca/:page' => 'biblioteca#show'
  resources :books
  get '/my_donations', to: 'books#index_my_donations', as: 'my_donations'
  get '/my_books', to: 'books#index_my_books', as: 'my_books'
  root 'biblioteca#show', page: 'home'
  post '/preview_book', to: 'books#preview'
  # devise
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions',
                                    omniauth_callbacks: 'users/omniauth_callbacks', users: 'users/' }
  resources :users, only: %i[show edit update]

  resources :notifications do
    collection do
      get :index
      post :mark_as_read
    end
  end
end

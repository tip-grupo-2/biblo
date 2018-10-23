# frozen_string_literal: true

Rails.application.routes.draw do
  get '/biblioteca/:page' => 'biblioteca#show'
  resources :books
  get '/my_donations', to: 'books#index_my_donations', as: 'my_donations'
  get '/my_books', to: 'books#index_my_books', as: 'my_books'
  root 'biblioteca#show', page: 'home'
  post '/preview_book', to: 'books#preview'
  get '/preview_book', to: 'books#preview'
  post '/preview_book_title', to: 'books#preview_title'
  post '/create_manual_book', to: 'books#create_manual'
  post '/manual_book', to: 'books#enter_manual'
  put '/finish_book/:id(.:format)', to: 'books#finish', as: 'finish_book'
  put '/start_book/:id(.:format)', to: 'books#start', as: 'start_book'
  get '/capture_barcode', to: 'books#capture_barcode'

  # devise
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions',
                                    omniauth_callbacks: 'users/omniauth_callbacks', users: 'users/' }
  resources :users, only: %i[show edit update]

  resources :notifications do
    member do
      get :show
      post :respond_request
    end
    collection do
      get :index
      post :mark_as_read
    end
  end
end

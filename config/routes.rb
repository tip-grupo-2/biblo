Rails.application.routes.draw do
  get "/biblioteca/:page" => "biblioteca#show"
  resources :books
  get "/my_books", to: "books#index_my_donations", as: "my_books"
  root "biblioteca#show", page: "home"
  # devise
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions',
                                              omniauth_callbacks: 'users/omniauth_callbacks' }
end

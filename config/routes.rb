Rails.application.routes.draw do
  get "/biblioteca/:page" => "biblioteca#show"

  root "biblioteca#show", page: "home"

  # devise
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions',
                                              omniauth_callbacks: 'users/omniauth_callbacks' }
end

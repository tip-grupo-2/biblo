Rails.application.routes.draw do
  get "/biblioteca/:page" => "biblioteca#show"
  resources :books
  root "biblioteca#show", page: "home"
end

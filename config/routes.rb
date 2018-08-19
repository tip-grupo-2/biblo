Rails.application.routes.draw do
  get "/biblioteca/:page" => "biblioteca#show"

  root "biblioteca#show", page: "home"
end

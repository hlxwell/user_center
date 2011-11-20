UserCenter::Application.routes.draw do
  get "/get_login_ticket.json" => "sso_api#get_login_ticket"
  get "/get_service_ticket.json" => "sso_api#get_service_ticket"

  match "/serviceValidate" => "validators#serviceValidate"
  match "/proxyValidate" => "validators#proxyValidate"

  resources :sessions
  resources :password_resets
  resource :user
  get "/user/activate/:token" => "users#activate", :as => :activate

  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout

  # resource :oauth do
  #   get :callback
  # end
  # match "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  root :to => 'sessions#new'

  # match ':controller(/:action(/:id(.:format)))'
end

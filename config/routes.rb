Rails.application.routes.draw do
  devise_for :staff
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  get '/settings', to: 'settings#index'
  put '/settings', to: 'settings#update'

  resources :staff

end

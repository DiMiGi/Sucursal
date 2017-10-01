Rails.application.routes.draw do

  devise_for :staff

  root to: 'home#index'

  get '/settings', to: 'settings#index'
  put '/settings', to: 'settings#update'

  resources :staff
  #resources :branch_offices

  # Servicio que entrega un JSON con regiones, y en cada region, sus comunas,
  # y anidadas sus sucursales. Sirve para poder buscar una sucursal por lugar.
  get '/regions/comunas/branch_offices', to: 'branch_offices#get_by_location'

end

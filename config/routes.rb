Rails.application.routes.draw do

  devise_for :staff

  root to: 'home#index'

  get '/settings', to: 'settings#index'
  put '/settings', to: 'settings#update'

  resources :staff

  scope :branch_offices do
    put ':id/attention_types', to: 'branch_offices#update_attention_types_estimations'
  end

  scope :staff do
    put ':id/time_blocks', to: 'staff#update_time_blocks'
  end

  # Servicio que entrega un JSON con regiones, y en cada region, sus comunas,
  # y anidadas sus sucursales. Sirve para poder buscar una sucursal por lugar.
  get '/regions/comunas/branch_offices', to: 'branch_offices#get_by_location'

end

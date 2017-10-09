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

  # Servicio que entrega las horas en donde se puede efectuar una reunion.
  # Los parametros son la sucursal (ID), tipo de atencion (ID), y el dia.
  get '/appointments/:yyyy/:mm/:dd/branch_office/:branch_office_id/attention_type/:attention_type_id',
  to: 'appointments#get_available_times'

  post '/appointments/schedule_appointment', to: 'appointments#schedule_appointment'

end

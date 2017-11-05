Rails.application.routes.draw do

  resources :reports
  resources :appointment, :controller=>:appointments
  devise_for :staff

  root to: 'home#index'

  get '/settings', to: 'settings#index'
  put '/settings', to: 'settings#update'

  put '/appointment/:id/finalize', to: 'appointments#finalize_appointment', as: 'finalize_appointment', controller: 'AppointmentsController'

  resources :staff

  post '/staff/:id/edit', to: 'staff#edit'
  post '/staff/:id',  to: 'staff#show'

  scope :branch_offices do
    put ':id/attention_types', to: 'branch_offices#update_attention_types_estimations'
  end

  scope :staff do
    put ':id/time_blocks', to: 'staff#update_time_blocks'
  end

  get '/staff/appointments/reassing', to: 'staff#new_reassign_appointments_to_executive'
  post '/staff/appointments/reassing', to: 'staff#reassign_appointments_to_executive'

  get '/staff/editar/select', to: 'staff#select'
  post '/staff/editar/select', to: 'staff#select'

  get '/staff/show/appointments/until/:days', to: 'staff#show_appointments', as: 'staff_show_appointments'


  scope :api do

    # Servicio que entrega un JSON con regiones, y en cada region, sus comunas,
    # y anidadas sus sucursales. Sirve para poder buscar una sucursal por lugar.
    get '/regions/comunas/branch_offices', to: 'branch_offices#get_by_location'

    # Necesita parametros --> latitude , longitude
    get '/branch_offices/nearest', to: 'branch_offices#nearest'

    get '/attention_types', to: 'attention_types#index'

    # Servicio que entrega las horas en donde se puede efectuar una reunion.
    # Los parametros son la sucursal (ID), tipo de atencion (ID), y el dia.
    get '/appointments/:yyyy/:mm/:dd/branch_office/:branch_office_id/attention_type/:attention_type_id',
    to: 'appointments#get_available_times'

    post '/appointments/schedule_appointment', to: 'appointments#schedule_appointment'

    get '/appointments/current', to: 'appointments#current_appointment'

    delete '/appointments/cancel', to: 'appointments#cancel_appointment'

  end

end
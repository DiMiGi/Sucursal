require 'rails_helper'

RSpec.describe AppointmentsController, type: :controller do

  pending "el cliente puede obtener las horas disponibles para agendar correctamente"

  pending "al cliente no se le entrega un listado de horas si ya tiene una hora agendada"

  pending "el cliente no puede realizar ningun servicio de agendamiento si ya tiene una hora agendada"

  pending "se obtiene un conjunto vacio de horas si el dia pedido es inferior al minimo permitido"

  pending "se obtiene un conjunto vacio de horas si el dia pedido es inferior al maximo permitido"

  pending "validar que una peticion que no tiene credenciales de autorizacion (cliente movistar) no puede acceder a ninguno de los servicios de agendamiento"

  pending "al realizar servicios de agendamiento (pedir listado de horas disponibles, etc), la variable client_id o ID de cliente debe ser no nula"


  describe "controlador para agendar horas" do


    it "no permite pedir citas dentro del mismo dia, o antes" do

      allow(Time).to receive(:now).and_return(Time.zone.parse('2017-10-03 23:59:59'))

      params = {
        client_id: 12,
        branch_office_id: 12,
        attention_type_id: 55,
        yyyy: 2017,
        mm: 10,
        dd: 3
      }

      get :get_available_times, params: params

      expect(response).to have_http_status :bad_request

      params[:dd] = 4

      get :get_available_times, params: params

      expect(response).to have_http_status :ok




    end



  end

end

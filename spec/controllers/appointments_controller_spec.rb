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

    before(:all) do
      @params = {
        client_id: 12,
        branch_office_id: 12,
        attention_type_id: 55,
        yyyy: 2017,
        mm: 10
      }
    end


    it "no permite pedir citas dentro del mismo dia, o antes" do

      allow(Time).to receive(:now).and_return(Time.zone.parse('2017-10-05 23:59:59'))

      [1, 2, 3, 4, 5].each do |d|
        @params[:dd] = d
        get :get_available_times, params: @params
        expect(response).to have_http_status :bad_request
        expect(response.body).to eq({ error: "Solo se puede pedir citas comenzando desde el día de mañana" }.to_json)
      end

      @params[:dd] = 6

      get :get_available_times, params: @params

      expect(response).to have_http_status :ok
    end


    it "permite solo reuniones dentro del rango especificado y no despues" do

      allow(Time).to receive(:now).and_return(Time.zone.parse('2017-10-05 23:59:59'))

      correct_days = [6, 7, 8, 9, 10, 11, 12]
      wrong_days = [13, 14, 15]

      correct_days.each do |d|
        @params[:dd] = d
        get :get_available_times, params: @params
        expect(response).to have_http_status :ok
      end

      wrong_days.each do |d|
        @params[:dd] = d
        get :get_available_times, params: @params

        expect(response.body).to eq({ error: "Solo se puede pedir citas hasta 7 días después comenzando desde el día de mañana" }.to_json)
        expect(response).to have_http_status :bad_request
      end
    end


    it "permite solo reuniones dentro del rango especificado y no despues, incluso si ese rango pasa de un mes a otro" do

      allow(Time).to receive(:now).and_return(Time.zone.parse('2017-10-28 23:59:59'))

      # Cada elemento de las listas son [mes, dia]
      correct_days = [[10, 29], [10, 30], [10, 31], [11, 1], [11, 2], [11, 3], [11, 4]]
      wrong_days = [[11, 5], [11, 6], [11, 7]]

      correct_days.each do |d|
        @params[:mm] = d[0]
        @params[:dd] = d[1]
        get :get_available_times, params: @params
        expect(response).to have_http_status :ok
      end

      wrong_days.each do |d|
        @params[:mm] = d[0]
        @params[:dd] = d[1]
        get :get_available_times, params: @params
        expect(response.body).to eq({ error: "Solo se puede pedir citas hasta 7 días después comenzando desde el día de mañana" }.to_json)
        expect(response).to have_http_status :bad_request
      end
    end

  end

end

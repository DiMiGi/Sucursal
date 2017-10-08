require 'rails_helper'

RSpec.describe AppointmentsController, type: :controller do

  pending "el cliente no puede realizar ningun servicio de agendamiento si ya tiene una hora agendada"

  pending "validar que una peticion que no tiene credenciales de autorizacion (cliente movistar) no puede acceder a ninguno de los servicios de agendamiento"

  pending "al realizar servicios de agendamiento (pedir listado de horas disponibles, etc), la variable client_id o ID de cliente debe ser no nula"


  describe "controlador para agendar horas" do

    before(:all) do
      @params = {
        client_id: 12,
        branch_office_id: 12,
        attention_type_id: 55,
        yyyy: 2017
      }
    end

    describe "algoritmo para detectar si tiene hora agendada ya, o no tiene" do

      before(:each) do
        allow(Time).to receive(:now).and_return(Time.zone.parse('2017-10-05 23:59:59'))
        a = FactoryGirl.create(:attention_type)
        b = FactoryGirl.create(:branch_office)
        @e = FactoryGirl.create(:executive, branch_office: b, attention_type: a)
        @params[:mm] = 10
        @params[:dd] = 6
        @already_has_appointment_msg = "No se puede consultar el servicio de agendas porque ya tiene una hora agendada"
      end

      it "no entrega el listado de horas disponibles si ya tiene una hora agendada" do
        get :get_available_times, params: @params
        expect(response).to have_http_status :ok
        expect(response.body).to eq({ times: [] }.to_json)
        @e.appointments << FactoryGirl.build(:appointment, client_id: @params[:client_id], time: Time.zone.parse('2017-10-08 23:59:59'))
        get :get_available_times, params: @params
        expect(response).to have_http_status :bad_request
        expect(response.body).to eq({ error: @already_has_appointment_msg }.to_json)
      end

      it "si la hora que tiene agendada esta en el mismo dia de hoy, tambien se arroja el error de que no se puede pedir hora si tiene una agendada" do
        @e.appointments << FactoryGirl.build(:appointment, client_id: @params[:client_id], time: Time.zone.parse('2017-10-05 23:59:59'))
        get :get_available_times, params: @params
        expect(response).to have_http_status :bad_request
        expect(response.body).to eq({ error: @already_has_appointment_msg }.to_json)
      end

      it "entrega el listado de horas disponibles en caso que la ultima hora del cliente sea inferior al dia actual (lo cual hace que automaticamente se consideren expiradas)" do
        @e.appointments << FactoryGirl.build(:appointment, client_id: @params[:client_id], time: Time.zone.parse('2017-10-04 23:59:59'))
        get :get_available_times, params: @params
        expect(response).to have_http_status :ok
        expect(response.body).to eq({ times: [] }.to_json)
      end

      it "toma la hora con mayor tiempo (mas lejana en el futuro) como la hora a considerar para saber si tiene hora agendada o no" do
        @e.appointments << FactoryGirl.build(:appointment, client_id: @params[:client_id], time: Time.zone.parse('2017-10-04 23:59:59'))
        get :get_available_times, params: @params
        expect(response).to have_http_status :ok
        expect(response.body).to eq({ times: [] }.to_json)

        @e.appointments << FactoryGirl.build(:appointment, client_id: @params[:client_id], time: Time.zone.parse('2017-10-06 23:59:59'))
        get :get_available_times, params: @params
        expect(response).to have_http_status :bad_request
        expect(response.body).to eq({ error: @already_has_appointment_msg }.to_json)
        # Si tomara las horas alreves, estaria tomando la primera que puse, la cual
        # no emite error por ya tener hora agendada.
      end


    end




    it "no entrega el listado de horas disponibles si se piden dentro del mismo dia, o antes" do

      allow(Time).to receive(:now).and_return(Time.zone.parse('2017-10-05 23:59:59'))
      @params[:mm] = 10

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
      @params[:mm] = 10

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


    it "obtiene un conjunto vacio si la sucursal no existe" do
      allow(Time).to receive(:now).and_return(Time.zone.parse('2017-10-28 23:59:59'))
      @params[:dd] = 30
      @params[:mm] = 10
      @params[:branch_office_id] = 100000
      get :get_available_times, params: @params
      expect(response).to have_http_status :ok
      expect(response.body).to eq({ times: [] }.to_json)
    end

    it "permite al cliente recibir los horarios disponibles en los cuales puede agendar una hora" do
      allow(Time).to receive(:now).and_return(Time.zone.parse('2017-10-01 23:59:59'))

      a = FactoryGirl.create(:attention_type)
      b = FactoryGirl.create(:branch_office)
      e = FactoryGirl.create(:executive, branch_office: b, attention_type: a)

      b.duration_estimations << FactoryGirl.build(:duration_estimation, attention_type_id: a.id, branch_office_id: b.id, duration: 15)
      e.time_blocks << FactoryGirl.build(:time_block, weekday: 0, hour: 9, minutes: 30)
      e.time_blocks << FactoryGirl.build(:time_block, weekday: 0, hour: 9, minutes: 45)

      @params[:dd] = 2
      @params[:mm] = 10
      @params[:branch_office_id] = b.id
      @params[:attention_type_id] = a.id
      get :get_available_times, params: @params
      expect(response).to have_http_status :ok
      expect(response.body).to eq({ times: [570, 585] }.to_json)

      e.appointments << FactoryGirl.build(:appointment, time: Time.zone.parse('2017-10-02 9:30:00'))
      get :get_available_times, params: @params
      expect(response).to have_http_status :ok
      expect(response.body).to eq({ times: [585] }.to_json)
    end


  end

end

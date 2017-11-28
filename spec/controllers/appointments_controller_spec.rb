require 'rails_helper'

RSpec.describe AppointmentsController, type: :controller do

  pending "cuando se utilizan los servicios, la ID del cliente debe obtenerse por medio de las credenciales de autenticacion (token, etc), y no un dato pasado por la peticion, ya que eso podria falsificarse."

  pending "el cliente no puede realizar ningun servicio de agendamiento si ya tiene una hora agendada"

  pending "validar que una peticion que no tiene credenciales de autorizacion (cliente movistar) no puede acceder a ninguno de los servicios de agendamiento"

  pending "al realizar servicios de agendamiento (pedir listado de horas disponibles, etc), la variable client_id o ID de cliente debe ser no nula"

  pending "verificar que si el cliente cancela su hora, ahora puede volver a pedir nuevas horas"

  pending "cuando se agenda una hora, el mensaje que se le entrega de vuelta al usuario esta formateado hh:mm y no h:m"


  before(:all) do
    @params = {
      client_id: 12,
      branch_office_id: 12,
      attention_type_id: 55,
      yyyy: 2017
    }
  end



  describe "accion del controlador para efectuar la toma de hora, y relacionados" do

    before(:each) do
      allow(Time).to receive(:current).and_return(Time.zone.parse('2017-10-05 23:59:59'))
      @executive = FactoryGirl.create(:executive)
      @attention_type_id = @executive.attention_type_id
      @branch_office_id = @executive.branch_office_id
      FactoryGirl.create(:duration_estimation,
        duration: 15,
        attention_type_id: @attention_type_id,
        branch_office_id: @branch_office_id)
      @params = {
        yyyy: 2017,
        mm: 10,
        dd: 9,
        hour: 14,
        minutes: 15,
        client_id: 1,
        attention_type_id: @attention_type_id,
        branch_office_id: @branch_office_id
      }
    end

    it "cuando pide su hora actual, entrega al cliente un JSON vacio si no tiene hora agendada" do
      get :current_appointment, params: { client_id: 166 }
      expect(response.body).to eq({}.to_json)
      expect(response).to have_http_status :ok
    end


    it "cuando pide su hora actual, entrega al cliente la cita actual que tiene" do

      FactoryGirl.create(:time_block, executive: @executive, hour: 14, minutes: 15, weekday: 0)
      @params[:client_id] = 166
      post :schedule_appointment, params: @params

      get :current_appointment, params: { client_id: 166 }
      json = JSON.parse response.body
      expect(json["client_id"]).to eq(166)
      expect(json["staff_id"]).to eq(@executive.id)
      expect(json["time"]).to include "2017-10-09"
      expect(json["time"]).to include "14:15:00"
      expect(response).to have_http_status :ok

    end

    it "permite al cliente cancelar su hora agendada correctamente, y al volver a obtener hora actual, ahora retorna nulo" do

      # Creo una cita
      FactoryGirl.create(:time_block, executive: @executive, hour: 14, minutes: 45, weekday: 0)
      @params[:client_id] = 200
      @params[:minutes] = 45
      post :schedule_appointment, params: @params

      # Obtengo la cita, y verifico que es la que pedi
      get :current_appointment, params: { client_id: 200 }
      json = JSON.parse response.body
      expect(json["client_id"]).to eq(200)
      expect(json["staff_id"]).to eq(@executive.id)
      expect(json["time"]).to include "2017-10-09"
      expect(json["time"]).to include "14:45:00"
      expect(response).to have_http_status :ok

      # Cuento cuantas citas estado "normal" y "cancelled" que existen
      count_normal = Appointment.where(status: :normal).count
      count_cancelled = Appointment.where(status: :cancelled).count

      # Cancelo la cita, y verifico que la cantidad de citas en estado "normal" disminuye en uno
      expect {
        delete :cancel_appointment, params: { client_id: 200 }
      }.to change(Appointment, :count).by 0

      expect(response).to have_http_status :no_content
      expect(Appointment.where(status: :normal).count).to eq(count_normal - 1)
      expect(Appointment.where(status: :cancelled).count).to eq(count_cancelled + 1)

      # Obtengo la cita actual, y el cliente no tiene ninguna agendada
      get :current_appointment, params: { client_id: 200 }
      expect(response.body).to eq({}.to_json)
      expect(response).to have_http_status :ok

    end

    it "acepta solo fechas validas" do
      @params[:dd] = 32
      post :schedule_appointment, params: @params
      expect(response).to have_http_status :bad_request
      expect(response.body).to eq({ error: "La fecha es incorrecta" }.to_json)
    end

    it "no acepta IDs negativas de clientes" do
      @params[:client_id] = -1
      post :schedule_appointment, params: @params
      expect(response).to have_http_status :bad_request
      expect(response.body).to eq({ error: "El cliente a efectuar el agendamiento no existe" }.to_json)
    end

    it "arroja error indicando que el bloque seleccionado no se encuentra disponible" do
      FactoryGirl.create(:time_block, executive: @executive, hour: 14, minutes: 0, weekday: 0)
      post :schedule_appointment, params: @params
      expect(response).to have_http_status :bad_request
      expect(response.body).to eq({ error: "La hora seleccionada no se encuentra disponible" }.to_json)
    end

    it "agenda la hora correctamente" do
      FactoryGirl.create(:time_block, executive: @executive, hour: 14, minutes: 15, weekday: 0)
      post :schedule_appointment, params: @params
      res = JSON.parse response.body
      expect(res["msg"]).to eq "La hora ha sido correctamente agendada a las 14:15"
      expect(response).to have_http_status :ok
    end

    it "agenda la hora correctamente" do
      FactoryGirl.create(:time_block, executive: @executive, hour: 8, minutes: 0, weekday: 0)
      @params[:hour] = 8
      @params[:minutes] = 0
      post :schedule_appointment, params: @params
      res = JSON.parse response.body
      expect(res["msg"]).to eq "La hora ha sido correctamente agendada a las 8:00"
      expect(response).to have_http_status :ok
    end

    it "prohibe al cliente agendar una hora si ya tiene una hora agendada, incluso si la hora pedida estaba correctamente pedida" do
      FactoryGirl.create(:time_block, executive: @executive, hour: 8, minutes: 0, weekday: 0)
      FactoryGirl.create(:appointment, time: Time.zone.parse("2017-10-9 14:10:00"), client_id: 1)
      post :schedule_appointment, params: @params
      expect(response.body).to eq({ error: "No se puede consultar el servicio de agendas porque ya tiene una hora agendada" }.to_json)
      expect(response).to have_http_status :bad_request
    end


  end


  describe "algoritmo para detectar si tiene hora agendada ya, o no tiene" do

    before(:each) do
      allow(Time).to receive(:current).and_return(Time.zone.parse('2017-10-05 23:59:59'))
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
      expect(response.body).to eq({ error: @already_has_appointment_msg }.to_json)
      expect(response).to have_http_status :bad_request
    end

    it "si la hora que tiene agendada esta en el mismo dia de hoy, tambien se arroja el error de que no se puede pedir hora si tiene una agendada" do
      @e.appointments << FactoryGirl.build(:appointment, client_id: @params[:client_id], time: Time.zone.parse('2017-10-05 23:59:59'))
      get :get_available_times, params: @params
      expect(response.body).to eq({ error: @already_has_appointment_msg }.to_json)
      expect(response).to have_http_status :bad_request
    end

    it "entrega el listado de horas disponibles en caso que la ultima hora del cliente sea inferior al dia actual (lo cual hace que automaticamente se consideren expiradas)" do
      @e.appointments << FactoryGirl.build(:appointment, client_id: @params[:client_id], time: Time.zone.parse('2017-10-04 23:59:59'))
      get :get_available_times, params: @params
      expect(response.body).to eq({ times: [] }.to_json)
      expect(response).to have_http_status :ok
    end

    it "toma la hora con mayor tiempo (mas lejana en el futuro) como la hora a considerar para saber si tiene hora agendada o no" do
      @e.appointments << FactoryGirl.build(:appointment, client_id: @params[:client_id], time: Time.zone.parse('2017-10-04 23:59:59'))
      get :get_available_times, params: @params
      expect(response.body).to eq({ times: [] }.to_json)
      expect(response).to have_http_status :ok

      @e.appointments << FactoryGirl.build(:appointment, client_id: @params[:client_id], time: Time.zone.parse('2017-10-06 23:59:59'))
      get :get_available_times, params: @params
      expect(response.body).to eq({ error: @already_has_appointment_msg }.to_json)
      expect(response).to have_http_status :bad_request
      # Si tomara las horas alreves, estaria tomando la primera que puse, la cual
      # no emite error por ya tener hora agendada.
    end

  end

  describe "metodo para obtener la hora agendada actual y activa del cliente" do

    before(:each) do
      allow(Time).to receive(:current).and_return(Time.zone.parse('2017-10-05 23:59:59'))
      @ctrl = AppointmentsController.new
    end

    it "obtiene la mas reciente" do
      FactoryGirl.create(:appointment, client_id: 3, time: Time.zone.parse('2017-10-06 15:00:00'))
      FactoryGirl.create(:appointment, client_id: 3, time: Time.zone.parse('2017-10-06 16:00:00'))
      FactoryGirl.create(:appointment, client_id: 4, time: Time.zone.parse('2017-10-06 18:00:00'))
      appointment = @ctrl.send(:get_client_appointment, 3)
      expect(appointment.time).to eq(Time.zone.parse '2017-10-06 16:00:00')
    end

    it "obtiene nil si hay solo canceladas" do
      FactoryGirl.create(:appointment, client_id: 3, status: :cancelled, time: Time.zone.parse('2017-10-06 15:00:00'))
      FactoryGirl.create(:appointment, client_id: 3, status: :cancelled, time: Time.zone.parse('2017-10-06 16:00:00'))
      appointment = @ctrl.send(:get_client_appointment, 3)
      expect(appointment).to be_nil
    end

    it "obtiene nil si hay solo expiradas" do
      FactoryGirl.create(:appointment, client_id: 3, time: Time.zone.parse('2017-10-03 15:00:00'))
      FactoryGirl.create(:appointment, client_id: 3, time: Time.zone.parse('2017-10-04 16:00:00'))
      appointment = @ctrl.send(:get_client_appointment, 3)
      expect(appointment).to be_nil
    end

    it "obtiene solo la mas reciente activa" do
      FactoryGirl.create(:appointment, client_id: 3, time: Time.zone.parse('2017-10-07 15:00:00'))
      FactoryGirl.create(:appointment, client_id: 3, status: :cancelled,time: Time.zone.parse('2017-10-07 16:00:00'))
      appointment = @ctrl.send(:get_client_appointment, 3)
      expect(appointment.time).to eq Time.zone.parse('2017-10-07 15:00:00')
    end

    it "obtiene solo las que estan despues o igual a hoy" do
      FactoryGirl.create(:appointment, client_id: 3, time: Time.zone.parse('2017-10-04 15:00:00'))
      FactoryGirl.create(:appointment, client_id: 3, time: Time.zone.parse('2017-10-05 00:00:00'))
      appointment = @ctrl.send(:get_client_appointment, 3)
      expect(appointment.time).to eq Time.zone.parse('2017-10-05 00:00:00')
      FactoryGirl.create(:appointment, client_id: 3, time: Time.zone.parse('2017-10-05 11:00:00'))
      appointment = @ctrl.send(:get_client_appointment, 3)
      expect(appointment.time).to eq Time.zone.parse('2017-10-05 11:00:00')
    end



  end






  it "no entrega el listado de horas disponibles si se piden dentro del mismo dia, o antes" do

    allow(Time).to receive(:current).and_return(Time.zone.parse('2017-10-05 23:59:59'))
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

    allow(Time).to receive(:current).and_return(Time.zone.parse('2017-10-05 23:59:59'))

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

    allow(Time).to receive(:current).and_return(Time.zone.parse('2017-10-28 23:59:59'))

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
    allow(Time).to receive(:current).and_return(Time.zone.parse('2017-10-28 23:59:59'))
    @params[:dd] = 30
    @params[:mm] = 10
    @params[:branch_office_id] = 100000
    get :get_available_times, params: @params
    expect(response).to have_http_status :ok
    expect(response.body).to eq({ times: [] }.to_json)
  end

  it "permite al cliente recibir los horarios disponibles en los cuales puede agendar una hora" do
    allow(Time).to receive(:current).and_return(Time.zone.parse('2017-10-01 23:59:59'))

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

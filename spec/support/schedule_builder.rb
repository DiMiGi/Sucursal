class ScheduleBuilder

  # Esta clase sirve simplemente para ejecutar las pruebas de caja negra
  # del algoritmo de planificacion, usando archivos JSON que almacenan
  # los datos. Estos archivos son leidos por esta clase y se crean todas las
  # filas necesarias. Ademas esta clase ejecuta las consultas, las cuales
  # pueden ser de tipo actualizacion o calculo.

  include ::RSpec::Matchers

  attr_accessor :data

  def initialize(filename)

    json_file = File.read(Rails.root.join("spec", "test_data", "scheduling", filename))

    @data = ActiveSupport::JSON.decode(json_file)

    @attention_types = []
    @branch_offices = []
    @executives = []
    @data["branch_offices"].each do |discretization|
      @branch_offices << FactoryGirl.create(:branch_office, minute_discretization: discretization)
    end

    @data["attention_types"].times { @attention_types << FactoryGirl.create(:attention_type) }

    @data["executives"].each do |executive|
      o = executive["branch_office"]
      a = executive["attention_type"]
      new_executive = FactoryGirl.create(:executive, branch_office: @branch_offices[o], attention_type: @attention_types[a])
      @executives << new_executive

      executive["appointments"].each do |appointment|
        split = appointment.split ' '
        yyyy = split[0].to_i
        mm = split[1].to_i
        dd = split[2].to_i
        hh = split[3].to_i
        min = split[4].to_i
        FactoryGirl.create(:appointment, :time => Time.zone.parse("#{yyyy}-#{mm}-#{dd} #{hh}:#{mm}:00"))
      end
    end

    @data["duration_estimations"].each do |estimation|
      b = estimation["branch_office"]
      a = estimation["attention_type"]
      d = estimation["duration"]
      FactoryGirl.create(:duration_estimation, duration: d, branch_office: @branch_offices[b], attention_type: @attention_types[a])
    end

    @data["global_days_off"].each do |day|
      #FactoryGirl.create(:global_day_off, day: Date.new(day["yyyy"], day["mm"], day["dd"]))
      FactoryGirl.create(:global_day_off, day: Time.zone.parse("#{day["yyyy"]}-#{day["mm"]}-#{day["dd"]}"))
    end

    @data["executive_days_off"].each do |day|
      executive = @executives[day["executive"]]
      date = Time.zone.parse("#{day["yyyy"]}-#{day["mm"]}-#{day["dd"]}")#Date.new(day["yyyy"], day["mm"], day["dd"])
      FactoryGirl.create(:executive_day_off, executive: executive, day: date)
    end

    @data["branch_office_days_off"].each do |day|
      branch_office = @branch_offices[day["branch_office"]]
      date = Time.zone.parse("#{day["yyyy"]}-#{day["mm"]}-#{day["dd"]}")#Date.new(day["yyyy"], day["mm"], day["dd"])
      FactoryGirl.create(:branch_office_day_off, branch_office: branch_office, day: date)
    end

    @data["time_blocks"].each do |time_block|
      executive = @executives[time_block["executive"]]
      weekday = time_block["weekday"]
      hour = time_block["hour"]
      minutes = time_block["minutes"]
      executive.time_blocks << FactoryGirl.build(:time_block, weekday: weekday, hour: hour, minutes: minutes)
      executive.save!
    end

  end




  def execute_query(query)
    type = query["type"]

    ctrl = AppointmentsController.new

    # Obtener todos los horarios donde se puede agendar una hora,
    # utilizando a todos los ejecutivos que atienden el tipo de atencion
    # en la sucursal indicada.
    if type == "assert_all"
      attention_type_id = @attention_types[query["attention_type"]].id
      branch_office_id = @branch_offices[query["branch_office"]].id
      correct_result = query["result"]
      split = query["day"].split ' '
      day = Time.zone.parse("#{split[0].to_i}-#{split[1].to_i}-#{split[2].to_i}").to_date
      #day = Date.new(split[0].to_i, split[1].to_i, split[2].to_i)
      result = ctrl.get_all_available_appointments(day: day, branch_office_id: branch_office_id, attention_type_id: attention_type_id)

      correct_result.each do |c|
        c["time"] = get_time c["time"]
      end

      expect(result.keys.length).to eq correct_result.length
      correct_result.each do |t|
        expect(result).to have_key t["time"].to_i
        t["ids"].each_with_index do |item, i|
          t["ids"][i] = @executives[t["ids"][i]].id
        end
        expect(t["ids"]).to eq result[t["time"].to_i]
      end
    end

    # Solo obtiene las horas donde se puede agendar, para un ejecutivo.
    if type == "assert_executive"
      branch_office_id = @branch_offices[query["branch_office"]].id
      executive_id = @executives[query["executive"]].id
      attention_type_id = @executives[query["executive"]].attention_type_id
      correct_result = query["result"]
      split = query["day"].split ' '
      day = Time.zone.parse("#{split[0].to_i}-#{split[1].to_i}-#{split[2].to_i}").to_date
      #day = Date.new(split[0].to_i, split[1].to_i, split[2].to_i)

      @data = ctrl.get_data(day: day, branch_office_id: branch_office_id, attention_type_id: attention_type_id)

      expect(correct_result).to eq [] if !@data.has_key? :executives
      expect(correct_result).to eq [] if !@data[:executives].has_key? executive_id

      time_blocks = @data[:executives][executive_id][:time_blocks]
      appointments = @data[:executives][executive_id][:appointments]
      duration = @data[:attention_duration]

      disc = @branch_offices[query["branch_office"]].minute_discretization

      result = ctrl.get_executive_available_appointments(discretization: disc, time_blocks: time_blocks, appointments: appointments, duration: duration)

      (0..correct_result.length-1).each do |i|
        correct_result[i] = get_time correct_result[i]
      end

      expect(result).to eq correct_result
    end

    # Actualiza la agenda agregando una cita, para el ejecutivo especificado.
    if type == "add_appointment"
      executive = @executives[query["executive"]]
      split = query["time"].split ' '
      time = Time.zone.parse("#{split[0].to_i}-#{split[1].to_i}-#{split[2].to_i} #{split[3].to_i}:#{split[4].to_i}")
      FactoryGirl.create(:appointment, executive: executive, time: time)
    end

    # Actualiza la manera en como la sucursal discretiza sus horarios.
    if type == "change_discretization"
      value = query["value"]
      b = query["branch_office"]
      @branch_offices[b].minute_discretization = value
      @branch_offices[b].save!
    end

    # Cambia la estimacion de la duracion de atencion que una sucursal le da
    # a un motivo de atencion.
    if type == "change_estimation"
      value = query["value"]
      b = query["branch_office"]
      a = query["attention_type"]
      if !value.nil?
        de = DurationEstimation.where(branch_office_id: @branch_offices[b], attention_type_id: @attention_types[a]).first
        de.duration = value
        de.save!
      else
        # Si se ha puesto el valor como null en el JSON, se elimina la estimacion.
        DurationEstimation.where(branch_office_id: @branch_offices[b], attention_type_id: @attention_types[a]).delete_all
      end
    end

    # Agrega un bloque de horario disponible a un ejecutivo.
    if type == "add_time_block"
      weekday = query["weekday"]
      hour = query["hour"]
      minutes = query["minutes"]
      e = query["executive"]
      @executives[e].time_blocks << FactoryGirl.build(:time_block, weekday: weekday, hour: hour, minutes: minutes)
    end
  end

  private

  def get_time(s)
    return s if s.class == Integer
    split = s.split ':'
    h = split[0].to_i
    m = split[1].to_i
    return (h*60) + m
  end


end

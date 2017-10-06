module Scheduling
  extend ActiveSupport::Concern
  include TimeRange

  # Este metodo obtiene todos los datos necesarios para poder hacer los algoritmos de planificacion.
  # La idea es que solo este metodo haga consultas a la base de datos, y los demas metodos, solo filtran
  # y procesan estos resultados.
  #
  # El tiempo de duracion de la atencion sera previamente redondeado
  # hacia el limite superior. Por ejemplo si el motivo de atencion fue configurado para durar 17 minutos,
  # pero la sucursal discretiza las horas usando intervalos de 10 minutos, entonces la duracion sera tomada
  # como que son 20 minutos.
  #
  # Los bloques horarios vienen ordenados.
  #
  # Las citas (appointment) tambien es una lista en donde las fechas estan ordenadas de menor a mayor.
  #
  # Tanto las horas de las citas como los bloques disponibles vienen en formato (hh*60) + mm, esto significa
  # que corresponde a la cantidad de minutos desde las 00:00AM. Por ejemplo una hora a las 8:15AM viene dado por
  # (8*60)+15 = 495
  #
  # El resultado de este metodo es un hash con todos los datos anidados. Ejemplo de retorno:
  # {:executives=>
  #   {2002=>
  #     {:appointments=>[840, 885, 910],
  #      :time_blocks=>[795, 825, 840, 885, 900, 960, 1050]}},
  #  :discretization=>5,
  #  :attention_duration=>20
  # }
  def get_data(day:, branch_office_id:, attention_type_id:)

    # Si hay al menos un feriado a nivel de sucursal o global, se retorna vacio.
    if !DayOff.where(day: day)
    .where("branch_office_id = ? OR (branch_office_id is NULL AND staff_id is NULL)", branch_office_id).first.nil?
      return {}
    end

    # Estas consultas se pueden optimizar para que hayan menos consultas (haciendo JOINs varios)
    # Recordar ejecutar los tests luego de cada modificacion $ rspec
    raise "Dia (parametro day) no es de tipo Date" if day.class != Date

    executives = Executive.select("staff.id, t.weekday, t.hour, t.minutes").joins("left join days_off as d on staff.id = d.staff_id and d.day = '#{day}'")
    .joins("left join time_blocks as t on staff.id = t.executive_id AND t.weekday = #{day_index(day)}")
    .where("d.id is NULL AND staff.branch_office_id = ? AND staff.attention_type_id = ? AND t.weekday is not NULL",
        branch_office_id,
        attention_type_id)

    return {} if executives.empty?

    de = DurationEstimation.includes(:branch_office).find_by(branch_office: branch_office_id, attention_type_id: attention_type_id)
    return {} if de.nil? || de.branch_office.nil? || de.branch_office.minute_discretization.nil?
    discretization = de.branch_office.minute_discretization
    duration = de.duration

    appointments = Appointment.find_by_day(day).where(executive: executives.map{|e| e[:id]})

    result = {}

    # Todo el siguiente codigo de este metodo sirve solamente para reestructurar
    # los resultados que se obtuvieron previamente, y encapsularlo en un solo
    # objeto (hash).

    result[:executives] = {}
    result[:discretization] = discretization
    result[:attention_duration] = ceil(duration, discretization)

    executives.each do |e|
      result[:executives][e.id] = {}
      result[:executives][e.id][:appointments] = []
      result[:executives][e.id][:time_blocks] = []
    end

    executives.each do |e|
      minutes = (e.hour * 60) + e.minutes
      result[:executives][e.id][:time_blocks] << minutes
    end


    appointments.each do |app|
      # Volver a redondearlo en caso que este valor haya cambiado desde
      # que se tomo la hora.
      app.time = Appointment.discretize(app.time, discretization)
      minutes = (app.time.hour * 60) + app.time.min
      result[:executives][app.staff_id][:appointments] << minutes
    end

    result[:executives].each do |key, executive|
      executive[:appointments].sort!
      executive[:time_blocks].sort!
      if executive[:time_blocks].empty?
        result[:executives].delete(key)
      end
    end

    return {} if !result[:executives].keys.any?
    return result

  end


  def get_executive_available_appointments(time_blocks:, appointments:, duration:)

    return [] if time_blocks.empty? || duration == 0

    time_blocks = compress(times: time_blocks, length: 15)
    appointments = compress(times: appointments, length: duration)

    ranges = get_available_ranges(time_blocks: time_blocks, appointments: appointments, duration: duration)

    times = []

    ranges.each do |r|
      a = r[0]
      b = r[1] - duration
      length = b - a
      n = 0
      while true
        t = a + (n * duration)
        break if t > b
        times << t
        n += 1
      end
    end

    return times

  end


  def get_all_available_appointments(day:, branch_office_id:, attention_type_id:)

    # Obtener todos los datos necesarios desde la base de datos.
    db_data = get_data(
      day: day,
      branch_office_id: branch_office_id,
      attention_type_id: attention_type_id)

    duration = db_data[:attention_duration]

    return {} if db_data.empty?
    return {} if duration == 0
    return {} if db_data[:executives].nil? || db_data[:executives].empty?

    result = Hash.new

    db_data[:executives].each do |id, executive|
      appointments = executive[:appointments]
      time_blocks = executive[:time_blocks]
      times = get_executive_available_appointments(time_blocks: time_blocks, appointments: appointments, duration: duration)

      times.each do |t|
        result[t] = [] if !result.has_key? t
        result[t] << id
      end
    end

    result.each do |key, value|
      result[key].sort! # Es necesario ordenarlo, o ya esta ordenado?
    end

    return result

  end



  # Recibe un tipo de dato Date y retorna cual dia es en el siguiente formato
  # 0 => Lunes
  # 1 => Martes
  # 2 => Miercoles
  # 3 => Jueves
  # 4 => Viernes
  # 5 => Sabado
  # 6 => Domingo
  def day_index(date)
    return 0 if date.monday?
    return 1 if date.tuesday?
    return 2 if date.wednesday?
    return 3 if date.thursday?
    return 4 if date.friday?
    return 5 if date.saturday?
    return 6 if date.sunday?
    raise "La fecha no logra retornar ninguno de los valores permitidos {0, 1, 2, 3, 4, 5, 6}"
  end


end

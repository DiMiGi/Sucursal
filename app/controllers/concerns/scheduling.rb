module Scheduling
  extend ActiveSupport::Concern

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
    executives = Executive.where("branch_office_id = ? AND attention_type_id = ?", branch_office_id, attention_type_id)

    appointments = Appointment.find_by_day(day).where(executive: executives)

    duration = DurationEstimation.find_by(branch_office_id: branch_office_id, attention_type_id: attention_type_id).duration

    discretization = BranchOffice.find(attention_type_id).minute_discretization

    time_blocks = TimeBlock.where(executive: executives, weekday: day_index(day))

    days_off_per_executive = ExecutiveDayOff.where(day: day).where(executive: executives)

    result = {}

    result[:executives] = {}
    result[:discretization] = discretization
    result[:attention_duration] = ceil(duration, discretization)

    executives.each do |exe|
      result[:executives][exe.id] = {}
      result[:executives][exe.id][:appointments] = []
      result[:executives][exe.id][:time_blocks] = []
    end

    appointments.each do |app|
      # Volver a redondearlo en caso que este valor haya cambiado desde
      # que se tomo la hora.
      app.time = Appointment.discretize(app.time, discretization)
      minutes = (app.time.hour * 60) + app.time.min
      result[:executives][app.staff_id][:appointments] << minutes
    end

    time_blocks.each do |block|
      minutes = (block.hour * 60) + block.minutes
      result[:executives][block.executive_id][:time_blocks] << minutes
    end

    result[:executives].each do |key, executive|
      executive[:appointments].sort!
      executive[:time_blocks].sort!
      if executive[:time_blocks].empty?
        result[:executives].delete(key)
      end
    end

    days_off_per_executive.each do |off|
      result[:executives].delete off.staff_id
    end

    if !result[:executives].keys.any?
      return {}
    end

    return result

  end



  # Esta funcion comprime listados de bloques disponibles. Considerar que
  # cada bloque tiene un valor fijo de 15 minutos. Eso significa que si se tiene
  # los bloques que comienzan en los minutos 800 y 815, el rango total de minutos disponibles es
  # de 800-815 (primer bloque) y desde 815-830 (segundo bloque), por lo tanto el rango total
  # sera desde 800 hasta 830. Ver los tests para comprender la descripcion del comportamiento
  # de esta funcion. Esta funcion tambien aprovecha de discretizar los valores para que se
  # ajusten a la cuadricula que la sucursal configura (el valor de discretizacion en minutos).
  # Tambien se puede usar para comprimir citas (appointments) y utilizar
  # otro valor como largo del bloque.
  def compress(times:, length:)
    def successor?(a, b, length)
      return true if a + length == b
      return false
    end
    return [] if times.empty?
    return [[floor(times[0], length), ceil(times[0]+length, length)]] if times.length == 1
    a = times[0]
    pairs = []
    i = 1
    while i < times.length do
      b = floor(times[i], length)
      if !successor?(times[i-1], b, length) && b != times[i-1]
        if pairs.empty? || floor(a, length) > ceil(pairs.last[1], length)
          pairs << [a, times[i-1]]
        else
          pairs.last[1] = times[i-1]
        end
        pairs.last[1] = pairs.last[1] + length
        a = b
      end
      if i == times.length - 1
        if pairs.empty? || floor(a, length) > ceil(pairs.last[1], length)
          pairs << [a, times.last]
        else
          pairs.last[1] = times.last
        end
        pairs.last[1] = pairs.last[1] + length
      end
      i = i + 1
    end

    # Discretizar los valores
    pairs.each do |pa|
      pa[0] = floor(pa[0], length)
      pa[1] = ceil(pa[1], length)
    end

    return pairs
  end


  # Une dos conjuntos.
  # Ver los tests para comprender su comportamiento.
  def union(r, s)

    r = r.flatten
    s = s.flatten

    i = 0
    j = 0

    result = []
    set = nil
    open_ranges = 0

    while j <= s.length
      while i < r.length
        if j < s.length && r[i] > s[j]
          break
        end

        if i % 2 == 0
          open_ranges = open_ranges + 1
          if open_ranges == 1
            # Significa que se acaba de abrir un conjunto
            set = [r[i], nil]
          end
        else
          open_ranges = open_ranges - 1
          if open_ranges == 0
            set[1] = r[i]
            result << set if result.empty? || set[0] != result.last[1]
            result.last[1] = set[1] unless set[0] != result.last[1]
          end
        end
        i = i + 1
      end

      if j % 2 == 0
        open_ranges = open_ranges + 1
        if open_ranges == 1
          # Significa que se acaba de abrir un conjunto
          set = [s[j], nil]
        end
      else
        open_ranges = open_ranges - 1
        if open_ranges == 0
          # Significa que se acaba de cerrar un conjunto
          set[1] = s[j]
          result << set if result.empty? || set[0] != result.last[1]
          result.last[1] = set[1] unless set[0] != result.last[1]
        end
      end

      j = j + 1
    end
    return result
  end



  # Recibe los bloques disponibles de un ejecutivo, y ademas sus citas,
  # y retorna los rangos de tiempo en donde tiene libre. Esta funcion
  # ejecuta una diferencia de conjuntos, ademas redondeando los valores
  # haciendolos cuadrar con la manera que la sucursal discretiza sus bloques.
  #
  # Solo retorna los bloques en los que hay suficiente tiempo para realizar una
  # atencion con la duracion indicada.
  #
  # Tanto la duracion como las citas y bloques disponibles deben ser previamente
  # discretizados. Esta funcion no realiza ningun redondeo ni verificacion.
  def get_ranges(time_blocks:, appointments:, duration:)
    r = time_blocks.flatten
    s = appointments.flatten
    i = 0
    j = 0
    result = []
    set = nil
    restriction_open = false
    available_open = false
    while j <= s.length
      while i < r.length
        if j < s.length && r[i] > s[j]
          break
        end
        if available_open = (i % 2 == 0)
          a = r[i]
          b = r[i+1]
          n = s[j]
          between = (j == s.length) || (a < n && n < b)
          set = [s[j+1]] if (restriction_open && between)
          set = [r[i]] if !restriction_open
        else
          if !restriction_open
            set << r[i]
            result << set if set[0] != set[1]
          end
        end
        i = i + 1
      end
      if restriction_open = (j % 2 == 0)
        if available_open
          set << s[j]
          result << set if set[0] != set[1]
        end
      else
        set = [s[j]] if available_open
      end
      j = j + 1
    end

    filtered = []
    result.each do |r|
      if r[1] - r[0] >= duration
        filtered << r
      end
    end

    return filtered
  end


  # Retorna un valor redondeado hacia arriba, usando el segundo argumento
  # como indicador de cuanto es el intervalo de discretizacion.
  # Por ejemplo si el intervalo es 7, los numeros se redondean hacia arriba
  # quedando en 0, 7, 14, 21, etc.
  def ceil(n, interval)
    div = n/interval
    mod = n%interval
    value = div * interval
    if mod != 0
      value += interval
    end
    value
  end

  def floor(n, interval)
    div = n/interval
    n = div * interval
    return n
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

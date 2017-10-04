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
  # El resultado de este metodo es un hash con todos los datos anidados. Ejemplo de retorno:
  # {
  #   :executives=>
  #   {2001=>{:appointments=>[Mon, 02 Oct 2017 13:30:00 UTC +00:00,Mon, 02 Oct 2017 13:30:00 UTC +00:00],
  #     :time_blocks=>[{:hh=>13, :mm=>0},{:hh=>13, :mm=>30},{:hh=>14, :mm=>0},{:hh=>14, :mm=>30},{:hh=>14, :mm=>45}]},
  #   2002=>{:appointments=>[Mon, 02 Oct 2017 14:00:00 UTC +00:00,Mon, 02 Oct 2017 14:45:00 UTC +00:00],
  #     :time_blocks=>[{:hh=>13, :mm=>15},{:hh=>13, :mm=>45},{:hh=>14, :mm=>0}]}},
  #   :discretization=>5,
  #   :attention_duration=>20
  # }
  def get_data(day:, branch_office_id:, attention_type_id:)

    # Si hay al menos un feriado a nivel de sucursal o global, se retorna vacio.
    if !DayOff.where(day: day)
    .where("branch_office_id = ? OR (branch_office_id is NULL AND staff_id is NULL)", branch_office_id).first.nil?
      return {}
    end

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
      result[:executives][app.staff_id][:appointments] << app.time
    end

    time_blocks.each do |block|
      result[:executives][block.executive_id][:time_blocks] << {
        :hh => block.hour,
        :mm => block.minutes
      }
    end

    result[:executives].each do |key, executive|

      executive[:time_blocks].sort! { |a, b|
        if a[:hh] == b[:hh]
          a[:mm] - b[:mm]
        else
          a[:hh] - b[:hh]
        end
      }

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

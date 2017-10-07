module TimeRange
  extend ActiveSupport::Concern


  # Esta funcion comprime listados de bloques disponibles. Considerar que
  # cada bloque tiene un valor fijo de 15 minutos. Eso significa que si se tiene
  # los bloques que comienzan en los minutos 800 y 815, el rango total de minutos disponibles es
  # de 800-815 (primer bloque) y desde 815-830 (segundo bloque), por lo tanto el rango total
  # sera desde 800 hasta 830. Ver los tests para comprender la descripcion del comportamiento
  # de esta funcion. Esta funcion tambien aprovecha de discretizar los valores para que se
  # ajusten a la cuadricula que la sucursal configura (el valor de discretizacion en minutos).
  # Tambien se puede usar para comprimir citas (appointments) y utilizar
  # otro valor como largo del bloque.

  def compress(times:, length:, discretization:)
    return [] if times.empty?
    return [[floor(times[0], discretization), ceil(times[0]+length, discretization)]] if times.length == 1
    a = times[0]
    pairs = []
    i = 1
    while i < times.length do
      b = times[i]
      if times[i-1] + length != b && b != times[i-1]
        if pairs.empty? || floor(a, discretization) > ceil(pairs.last[1], discretization)
          pairs << [a, times[i-1]]
        else
          pairs.last[1] = times[i-1]
        end
        pairs.last[1] = pairs.last[1] + length
        a = b
      end
      if i == times.length - 1
        if pairs.empty? || floor(a, discretization) > ceil(pairs.last[1], discretization)
          pairs << [a, times.last]
        else
          pairs.last[1] = times.last
        end
        pairs.last[1] = pairs.last[1] + length
      end
      i += 1
    end

    # Discretizar los valores
    pairs.each do |pa|
      pa[0] = floor(pa[0], discretization)
      pa[1] = ceil(pa[1], discretization)
    end

    return pairs
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
  def get_available_ranges(time_blocks:, appointments:, duration:)
    r = time_blocks.flatten
    s = appointments.flatten
    i = j = 0
    result = []
    set = nil
    restriction_open = available_open = false
    while j <= s.length
      while i < r.length
        break if j < s.length && r[i] > s[j]
        if available_open = i.even?
          between = (j == s.length) || (r[i] < s[j] && s[j] < r[i+1])
          set = [s[j+1]] if (restriction_open && between)
          set = [r[i]] if !restriction_open
        else
          if !restriction_open
            set << r[i]
            result << set if set[0] != set[1]
          end
        end
        i += 1
      end
      if restriction_open = j.even?
        if available_open
          set << s[j]
          result << set if set[0] != set[1]
        end
      else
        set = [s[j]] if available_open
      end
      j += 1
    end

    filtered = []
    result.each do |r|
      filtered << r if r[1] - r[0] >= duration
    end

    return filtered
  end


  # Retorna un valor redondeado hacia arriba, usando el segundo argumento
  # como indicador de cuanto es el intervalo de discretizacion.
  # Por ejemplo si el intervalo es 7, los numeros se redondean hacia arriba
  # quedando en 0, 7, 14, 21, etc.
  def ceil(n, interval)
    value = (n/interval) * interval
    value += interval if n%interval != 0
    value
  end

  def floor(n, interval)
    (n/interval) * interval
  end

end

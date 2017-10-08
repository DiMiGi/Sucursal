class AppointmentsController < ApplicationController

  include Scheduling

  def get_available_times

    # Aca se debe implementar una politica de acceso. El usuario debe estar
    # autorizado para ejecutar esta accion. Como aun no se tiene la integracion
    # con el resto del sistema movistar, queda pendiente.

    # Se debe retornar codigo de estado 403 Forbidden o bien 401 Unauthorized.
    # Por mientras, dejo que se pase la ID del cliente por query params, es decir
    # /url?client_id = 123
    # Tambien se deja como Pending en los rspec (pruebas unitarias).

    client_id = params[:client_id]

    # ------------------------------------------

    # Obtengo los parametros de la URL
    branch_office_id = params[:branch_office_id].to_i
    attention_type_id = params[:attention_type_id].to_i

    # Obtengo los parametros del dia
    yyyy = params[:yyyy].to_i
    mm = params[:mm].to_i
    dd = params[:dd].to_i

    # Verifico que el dia formado sea correcto. En caso que no lo sea,
    # se debe arrojar un error.
    begin
      day = Time.new(yyyy, mm, dd)
    rescue => e
      msg = "La fecha es incorrecta"
      render :json => { :error => msg }, :status => :bad_request
      return
    end


    # Verificar que la fecha sea mayor al limite inferior, el cual
    # corresponde al dia de manana (la hora es el inicio de ese dia 00:00:00).
    tomorrow = Time.now.beginning_of_day.tomorrow

    if day.beginning_of_day < tomorrow
      msg = "Solo se puede pedir citas comenzando desde el día de mañana"
      render :json => { :error => msg }, :status => :bad_request
      return
    end


    # Obtengo todos los tiempos en donde es posible agendar una hora.
    times = get_all_available_appointments(
      day: day.to_date,
      branch_office_id: branch_office_id,
      attention_type_id: attention_type_id)

    # Dado que la funcion retorna todos los tiempos, pero cada tiempo contiene
    # listas de las IDs de ejecutivos que tienen ese bloque libre, es necesario
    # filtrar ese resultado, y entregarle al cliente solo los bloques, sin las
    # IDs de los ejecutivos.
    #
    # Este es un ejemplo de resultado (pseudocodigo):
    # {
    #   480 -> [0, 1, 2]
    #   500 -> [0]
    #   510 -> [0, 2]
    # }
    # En donde el primer numero es la clave del Hash, que representa el bloque,
    # en formato (hora*60)+minuto, y el valor correspondiente a esa clave
    # es la lista de IDs de ejecutivos que lo tienen disponible.

    only_times = times.keys
    times.keys.sort!


    render :json => { times: only_times }, :status => :ok

  end


end

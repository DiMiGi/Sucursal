module Notification
  extend ActiveSupport::Concern

  # Obtiene como parametros dos dias (inicio y fin), y retorna un listado
  # de notificaciones las cuales estaran debidamente espaciadas en ese rango.
  #
  # Si el rango es muy chico, entonces pondra menos notificaciones que si el
  # rango es grande, y siempre habra un limite de notificaciones, para que
  # no exceda esa cantidad de notificaciones.
  #
  #
  def create_notifications(start:, finish:, quantity:)

    notifs = []

    minutes_before_appointment = 120

    if(finish.day - start.day >= 2)
      n = Hash.new
      n[:title] = "No olvides tu cita para mañana"
      n[:text] = "En 24 horas tienes tu cita en sucursal Movistar. Ver detalles."
      n[:at] = (finish - 24.hours)
      notifs << n
    end


    last = Hash.new
    last[:title] = "Recuerda que tienes una cita"
    last[:text] = "Tienes una cita hoy a las #{finish.strftime("%H:%M")} en sucursal Movistar. Ver detalles."
    last[:at] = finish - minutes_before_appointment.minutes

    notifs << last

    return notifs

  end

end

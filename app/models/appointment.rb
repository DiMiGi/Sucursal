class Appointment < ApplicationRecord

  belongs_to :executive, foreign_key: 'staff_id'
  validates_presence_of :executive
  validates_presence_of :time

  after_validation :discretization


  private

  # Hace que el tiempo de la reunion quede redondeada a la manera como esta
  # sucursal discretiza sus horas.
  # La sucursal tiene un atributo para discretizar tiempos. Por ejemplo si
  # ese atributo son 5 minutos, y la reunion fue pedida a las 13:41:56, entonces
  # el resultado final sera 13:40:00. Si el tiempo de discretizacion fuese
  # de 1 minuto, entonces la hora finalmente quedara agendada para las 13:41:00.
  # El bloque de discretizacion comienza al inicio de la hora, lo que quiere decir que
  # si el valor es 7, entonces los valores a los cuales se redondea son
  # hh:00:ss, hh:07:ss, hh:14:ss, hh:21:ss, etc.
  def discretization
    return if executive.nil?
    return if time.nil?

    discretization = self.executive.branch_office.minute_discretization

    # Hacer que los segundos queden en 0
    self.time = self.time.beginning_of_minute

    a = 0
    min = self.time.min

    while a <= 60 do
      b = a + discretization
      if a <= min && min < b
        self.time = self.time.change(:min => a)
        break
      end
      a = a + discretization
    end

  end

end

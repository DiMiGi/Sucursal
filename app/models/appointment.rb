class Appointment < ApplicationRecord

  belongs_to :executive, foreign_key: 'staff_id'
  belongs_to :staff_took_appointment, :class_name => 'Executive', foreign_key: 'staff_id',  optional: true
  validates_presence_of :executive
  validates_presence_of :time
  validates_presence_of :client_id

  enum status: [ :normal, :cancelled ]

  after_validation :auto_discretization


  # Pasar un argumento de tipo Date, y retorna los appointments (citas) que hayan
  # en ese dia. Luego se le puede colocar mas where() para filtrar mas (crea solo una consulta).
  # Por ejemplo Appointment.find_by_day(Date.new(2017, 1, 1)).where(:executive => un_ejecutivo_123)
  def self.find_by_day(day1)
    where("? <= time AND time < ?", day1, day1.tomorrow)
  end


  def self.discretize(time, value)
    return time if value.nil?
    return time if time.nil?
    # Hacer que los segundos queden en 0
    time = time.beginning_of_minute
    min = time.min
    min = value * (min/value)
    time = time.change(min: min)
    return time
  end


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
  # Esto es solo para validar la hora a guardar en la BD, y mantener la integridad y coherencia.
  # En la practica, las horas deberian venir redondeadas desde antes por parte de
  # los controladores, front-end, etc.
  def auto_discretization
    return if executive.nil?
    return if time.nil?
    value = self.executive.branch_office.minute_discretization
    time = self.class.discretize(self.time, value)
    self.time = self.time.change(min: time.min)
  end

end

class Executive < Staff


  belongs_to :branch_office
  belongs_to :attention_type, optional: true
  has_many :time_blocks, dependent: :delete_all
  has_many :appointments, :foreign_key => "staff_id"
  has_many :days_off, class_name: "ExecutiveDayOff", dependent: :delete_all, :foreign_key => "staff_id"

  validates_presence_of :branch_office


  # Método para la logica de reasignacion de horas (No implemetado pero se considera la lógica)
  def reassign_appointments_to(replacement_executive)
    return false if !replacement_executive.is_a?(Executive)
    return false if !can_assign_appointmnets_to?(replacement_executive)
    add_appointments_to(replacement_executive, appointments)
    return replacement_executive.save
  end

  # Método encargado de manejar la logica de implementacion de insercion de las horas agendadas (no implementado con ejecutivos que contengan horarios)
  def add_appointments_to(excecutive,appointments)
    return false if !excecutive.is_a?(Executive)
    #return false if !appointments.is_a?(Appointment)
    excecutive.appointments << appointments
    return true
  end

  # Método que debe verificar que es valido asignar horas al ejecutivo desde el objeto (self)
  def can_assign_appointmnets_to?(executive)
    return true
  end
  
end

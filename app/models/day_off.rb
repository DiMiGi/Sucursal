class CorrectlyAssigned < ActiveModel::Validator
  def validate(day_off)

    staff = day_off.staff
    branch_office = day_off.branch_office

    # Valida que sea feriado global, por sucursal, o por ejecutivo, pero no una mezcla
    # entre esas.

    # Es un feriado global de la aplicacion.
    if staff.nil? && branch_office.nil?
      return
    end

    # Es un feriado con alcance para una sucursal completa.
    if staff.nil? && !branch_office.nil?
      return
    end

    # Error, ambas IDs estan puestas. Solo puede haber una, o ninguna.
    if !staff.nil? && !branch_office.nil?
      day_off.errors[:staff] << 'El dia ausente corresponde a una sucursal, por lo tanto no puede tener personal ejecutivo asignado'
      return
    end

    # Tiene personal asignado, pero no es ejecutivo. No hay sucursal asignada.
    if !staff.nil? && !staff.executive? && branch_office.nil?
      day_off.errors[:staff] << 'El dia ausente solo puede ser asignado a un personal de tipo ejecutivo.'
      return
    end
  end
end


class CorrectDay < ActiveModel::Validator
  def validate(staff)

    # Implementar un validador para el dia.
  end
end



class DayOff < ApplicationRecord

  self.table_name = "days_off"

  belongs_to :branch_office, optional: true
  belongs_to :staff, optional: true

  validates_presence_of :day

  validates_with CorrectlyAssigned
  validates_with CorrectDay


end

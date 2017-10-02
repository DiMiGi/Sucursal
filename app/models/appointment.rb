class AppointmentCorrectlyAssigned < ActiveModel::Validator
  def validate(appointment)
    if !appointment.staff.executive?
      appointment.errors[:staff] << 'Solo se puede tomar una cita con un ejecutivo'
      return
    end

    if appointment.staff.attention_type.nil?
      appointment.errors[:staff] << 'El ejecutivo no atiende ningun motivo de atención'
    end
  end
end

class Appointment < ApplicationRecord

  belongs_to :staff

  validates_presence_of :staff
  validates_presence_of :day

  validates_with AppointmentCorrectlyAssigned
end

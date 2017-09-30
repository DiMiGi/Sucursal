class SucursalAsignadaCorrectamente < ActiveModel::Validator
  def validate(staff)

    # Valida que un usuario administrador no tenga asignada una sucursal,
    # y que el resto de los usuarios si tengan una.

    if staff.admin? && staff.branch_office != nil
      staff.errors[:branch_office] << 'El usuario administrador no puede tener asignada una sucursal'
    end

    if !staff.admin? && staff.branch_office == nil
      staff.errors[:branch_office] << 'El usuario debe tener asignada una sucursal'
    end
  end
end

class Staff < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum position: [:executive, :supervisor, :manager, :admin]

  belongs_to :branch_office, optional: true

  auto_strip_attributes :names, :squish => true
  auto_strip_attributes :first_surname, :squish => true
  auto_strip_attributes :second_surname, :squish => true

  validates_length_of :names, :minimum => 1
  validates_length_of :first_surname, :minimum => 1

  validates_with SucursalAsignadaCorrectamente

  after_validation :mayusculas_nombre

  def nombre_completo
    completo = names + ' ' + first_surname
    if second_surname
      completo = completo + ' ' + second_surname
    end
    return completo
  end

  def executive?
    position == :executive.to_s
  end

  def supervisor?
    position == :supervisor.to_s
  end

  def manager?
    position == :manager.to_s
  end

  def admin?
    position == :admin.to_s
  end

  private
  def mayusculas_nombre
    return unless errors.blank?
    self.names = self.names.split.map(&:capitalize)*' '
    self.first_surname = self.first_surname.split.map(&:capitalize)*' '
    self.second_surname = self.second_surname.split.map(&:capitalize)*' ' if self.second_surname
  end


end

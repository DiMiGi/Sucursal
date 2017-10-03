class Staff < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  auto_strip_attributes :names, :squish => true
  auto_strip_attributes :first_surname, :squish => true
  auto_strip_attributes :second_surname, :squish => true

  validates_length_of :names, :minimum => 1
  validates_length_of :first_surname, :minimum => 1
  validates_presence_of :type

  after_validation :capitalize_name

  def full_name
    full = names + ' ' + first_surname
    if second_surname
      full = full + ' ' + second_surname
    end
    return full
  end

  def name_surname
    names.split(" ")[0] + " " + first_surname
  end

  def executive?
    self.is_a? Executive
  end

  def supervisor?
    self.is_a? Supervisor
  end

  def manager?
    self.is_a? Manager
  end

  def admin?
    self.is_a? Admin
  end

  private
  def capitalize_name
    return unless errors.blank?
    self.names = self.names.split.map(&:capitalize)*' '
    self.first_surname = self.first_surname.split.map(&:capitalize)*' '
    self.second_surname = self.second_surname.split.map(&:capitalize)*' ' if self.second_surname
  end


end

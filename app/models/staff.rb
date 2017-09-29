class Staff < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable



  enum position: [:executive, :supervisor, :manager, :admin]

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
end

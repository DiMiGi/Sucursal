class Appointment < ApplicationRecord

  belongs_to :executive
  validates_presence_of :executive
  validates_presence_of :day

end

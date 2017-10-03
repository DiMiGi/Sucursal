class Appointment < ApplicationRecord

  belongs_to :executive, foreign_key: 'staff_id'
  validates_presence_of :executive
  validates_presence_of :day

end

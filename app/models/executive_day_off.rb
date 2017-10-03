class ExecutiveDayOff < DayOff

  belongs_to :executive, foreign_key: 'staff_id' 
  validates_presence_of :executive

end

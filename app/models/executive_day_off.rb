class ExecutiveDayOff < DayOff

  belongs_to :executive
  validates_presence_of :executive

end

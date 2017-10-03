class DayOff < ApplicationRecord

  self.table_name = "days_off"
  validates_presence_of :day
  validates_presence_of :type

end

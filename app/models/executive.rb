class Executive < Staff

  belongs_to :branch_office
  belongs_to :attention_type, optional: true
  has_many :time_blocks
  has_many :appointments
  has_many :days_off, :class_name => "ExecutiveDayOff"

  validates_presence_of :branch_office

end

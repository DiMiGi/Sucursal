class Executive < Staff


  belongs_to :branch_office
  belongs_to :attention_type, optional: true
  has_many :time_blocks, dependent: :delete_all
  has_many :appointments, :foreign_key => "staff_id"
  has_many :days_off, class_name: "ExecutiveDayOff", dependent: :delete_all, :foreign_key => "staff_id"

  validates_presence_of :branch_office

end

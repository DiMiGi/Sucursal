class Executive < Staff

  belongs_to :branch_office
  belongs_to :attention_type, optional: true
  has_many :time_blocks
  has_many :appointments

  validates_presence_of :branch_office

end

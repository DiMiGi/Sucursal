class Supervisor < Staff

  belongs_to :branch_office
  belongs_to :attention_type, optional: true
  validates_presence_of :branch_office

end

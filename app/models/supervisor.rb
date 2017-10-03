class Supervisor < Staff

  belongs_to :branch_office
  belongs_to :attention_type, optional: true

end

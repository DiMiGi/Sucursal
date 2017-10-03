class BranchOfficeDayOff < DayOff

  belongs_to :branch_office
  validates_presence_of :branch_office

end

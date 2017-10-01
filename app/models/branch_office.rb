class BranchOffice < ApplicationRecord

  belongs_to :comuna
  has_many :staff

  auto_strip_attributes :address, :squish => true
  validates_length_of :address, :minimum => 1


  def full_address
    comuna = self.comuna
    region = comuna.region
    @branch_office = "#{self.address}, #{comuna.name}, #{region.name}"
  end

end

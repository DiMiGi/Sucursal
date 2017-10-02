class BranchOffice < ApplicationRecord

  belongs_to :comuna
  has_many :staff

  auto_strip_attributes :address, :squish => true
  validates_length_of :address, :minimum => 1

  has_many :duration_estimations
  has_many :attention_types, :through => :duration_estimations


  def full_address
    comuna = self.comuna
    region = comuna.region
    @branch_office = "#{self.address}, #{comuna.name}, #{region.name}"
  end

end

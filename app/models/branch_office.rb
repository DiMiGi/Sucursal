class BranchOffice < ApplicationRecord

  belongs_to :comuna
  has_many :staff

  auto_strip_attributes :address, :squish => true
  validates_length_of :address, :minimum => 1

  has_many :duration_estimations
  has_many :attention_types, :through => :duration_estimations

  has_many :days_off, class_name: "BranchOfficeDayOff", dependent: :delete_all

  # Divisores de 60.
  validates_inclusion_of :minute_discretization, :in => [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60], :allow_nil => false


  def full_address
    comuna = self.comuna
    region = comuna.region
    @branch_office = "#{self.address}, #{comuna.name}, #{region.name}"
  end

  def distance(latitude:, longitude:)

    d_lat = latitude - self.latitude
    d_lon = longitude - self.longitude

    Math.sqrt((d_lat**2) + (d_lon**2))
  end

end

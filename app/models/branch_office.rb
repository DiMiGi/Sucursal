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

    d_lat = deg2rad(latitude - self.latitude)
    d_lon = deg2rad(longitude - self.longitude)

    a = Math.sin(d_lat/2) * Math.sin(d_lat/2) + Math.cos(deg2rad(latitude)) * Math.cos(deg2rad(self.latitude)) * Math.sin(d_lon/2) * Math.sin(d_lon/2)

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))

    # R = 6371 => radio de la tierra en Km
    distanciaEnKm = 6371 * c
  end

  def deg2rad(grados)
    return grados * (Math::PI/180)
  end

end

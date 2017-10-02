class AttentionType < ApplicationRecord

  auto_strip_attributes :name, :squish => true
  validates_length_of :name, :minimum => 1

  has_many :duration_estimation
  has_many :branch_offices, :through => :duration_estimations

end

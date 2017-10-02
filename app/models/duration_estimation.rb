class DurationEstimation < ApplicationRecord

  belongs_to :attention_type
  belongs_to :branch_office
  validates_numericality_of :duration, less_than_or_equal_to: 60, greater_than: 0

end

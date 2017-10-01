class AttentionType < ApplicationRecord

  auto_strip_attributes :name, :squish => true
  validates_length_of :name, :minimum => 1

end

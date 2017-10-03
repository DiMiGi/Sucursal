class TimeBlock < ApplicationRecord

  belongs_to :executive

  validates_inclusion_of :weekday, :in => [0, 1, 2, 3, 4, 5, 6], :allow_nil => false

  validates_inclusion_of :hour, :in => [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23], :allow_nil => false

  validates_inclusion_of :minutes, :in => [0, 15, 30, 45], :allow_nil => false


end

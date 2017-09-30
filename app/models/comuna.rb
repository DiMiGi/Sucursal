class Comuna < ApplicationRecord

  belongs_to :region
  has_many :branch_office

end

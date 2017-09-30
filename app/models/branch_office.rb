class BranchOffice < ApplicationRecord

  belongs_to :comuna
  has_many :staffs

end

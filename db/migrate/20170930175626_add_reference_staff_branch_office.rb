class AddReferenceStaffBranchOffice < ActiveRecord::Migration[5.1]
  def change

    add_reference :staffs, :branch_office, null: true, foreign_key: true 

  end
end

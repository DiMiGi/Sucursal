class AddReferenceStaffBranchOfficeAndAttentionType < ActiveRecord::Migration[5.1]
  def change

    add_reference :staff, :branch_office, null: true, foreign_key: true
    add_reference :staff, :attention_type, null: true, foreign_key: true

  end
end

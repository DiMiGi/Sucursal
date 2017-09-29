class AddTypeToStaff < ActiveRecord::Migration[5.1]
  def change
    add_column :staffs, :position, :integer, default: 0
  end
end

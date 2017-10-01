class AddTypeToStaff < ActiveRecord::Migration[5.1]
  def change
    add_column :staff, :position, :integer, default: 0
  end
end

class AddNameToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :staffs, :names, :string
    add_column :staffs, :first_surname, :string
    add_column :staffs, :second_surname, :string
  end
end

class AddNameToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :staff, :names, :string
    add_column :staff, :first_surname, :string
    add_column :staff, :second_surname, :string
  end
end

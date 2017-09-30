class AddUsernameToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :staffs, :fullname, :string
  end
end

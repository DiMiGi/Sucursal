class CreateBranchOffices < ActiveRecord::Migration[5.1]
  def change
    create_table :branch_offices do |t|

      t.string :address, null: false, limit: 60
      t.belongs_to :comuna, index: true
      t.integer :minute_discretization, null: false, default: 5
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.timestamps
    end
  end
end

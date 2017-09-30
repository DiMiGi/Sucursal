class CreateBranchOffices < ActiveRecord::Migration[5.1]
  def change
    create_table :branch_offices do |t|

      t.string :direccion, null: false, limit: 60
      t.belongs_to :comuna, index: true
      t.timestamps
    end
  end
end

class CreateComunas < ActiveRecord::Migration[5.1]
  def change
    create_table :comunas do |t|

      t.string :name, null: false, limit: 60
      t.belongs_to :region, index: true
      t.timestamps
    end
  end
end

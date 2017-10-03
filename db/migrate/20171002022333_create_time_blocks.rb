class CreateTimeBlocks < ActiveRecord::Migration[5.1]
  def change
    create_table :time_blocks, id: false do |t|
      t.integer :weekday
      t.integer :hour
      t.integer :minutes
      t.belongs_to :executive, index: true
      t.timestamps
    end

    add_index :time_blocks, [:executive_id, :weekday, :hour, :minutes], name: "index_unique_time_block", unique: true

  end
end

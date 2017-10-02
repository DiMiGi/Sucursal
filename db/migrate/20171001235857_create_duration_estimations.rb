class CreateDurationEstimations < ActiveRecord::Migration[5.1]
  def change
    create_table :duration_estimations do |t|
      t.integer :duration
    end

    add_reference :duration_estimations, :branch_office, foreign_key: true
    add_reference :duration_estimations, :attention_type, foreign_key: true

    add_index :duration_estimations, [:branch_office_id, :attention_type_id], name: "index_branch_attention", unique: true

  end
end

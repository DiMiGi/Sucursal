class CreateAttentionTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :attention_types do |t|

      t.string :name, :null => false
      t.timestamps
    end
  end
end

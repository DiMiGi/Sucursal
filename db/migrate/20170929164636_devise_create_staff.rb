class DeviseCreateStaff < ActiveRecord::Migration[5.1]
  def change
    create_table :staff do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.string :type, limit: 16

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.string :names
      t.string :first_surname
      t.string :second_surname

      t.timestamps null: false
    end

    add_index :staff, :email,                unique: true
    add_index :staff, :reset_password_token, unique: true
    add_reference :staff, :branch_office, null: true, foreign_key: true
    add_reference :staff, :attention_type, null: true, foreign_key: true
    # add_index :staff, :confirmation_token,   unique: true
    # add_index :staff, :unlock_token,         unique: true
  end
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171002213522) do

  create_table "appointments", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.integer "staff_id"
    t.datetime "time", null: false
    t.integer "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "staff_took_appointment_id"
    t.index ["staff_id"], name: "index_appointments_on_staff_id"
  end

  create_table "attention_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "branch_offices", force: :cascade do |t|
    t.string "address", limit: 60, null: false
    t.integer "comuna_id"
    t.integer "minute_discretization", default: 5, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comuna_id"], name: "index_branch_offices_on_comuna_id"
  end

  create_table "comunas", force: :cascade do |t|
    t.string "name", limit: 60, null: false
    t.integer "region_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["region_id"], name: "index_comunas_on_region_id"
  end

  create_table "days_off", force: :cascade do |t|
    t.integer "branch_office_id"
    t.integer "staff_id"
    t.date "day", null: false
    t.string "type", limit: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_office_id"], name: "index_days_off_on_branch_office_id"
    t.index ["staff_id"], name: "index_days_off_on_staff_id"
  end

  create_table "duration_estimations", force: :cascade do |t|
    t.integer "duration"
    t.integer "branch_office_id"
    t.integer "attention_type_id"
    t.index ["attention_type_id"], name: "index_duration_estimations_on_attention_type_id"
    t.index ["branch_office_id", "attention_type_id"], name: "index_branch_attention", unique: true
    t.index ["branch_office_id"], name: "index_duration_estimations_on_branch_office_id"
  end

  create_table "regions", force: :cascade do |t|
    t.string "name", limit: 60, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "staff", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "type", limit: 16
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "names"
    t.string "first_surname"
    t.string "second_surname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "branch_office_id"
    t.integer "attention_type_id"
    t.index ["attention_type_id"], name: "index_staff_on_attention_type_id"
    t.index ["branch_office_id"], name: "index_staff_on_branch_office_id"
    t.index ["email"], name: "index_staff_on_email", unique: true
    t.index ["reset_password_token"], name: "index_staff_on_reset_password_token", unique: true
  end

  create_table "time_blocks", force: :cascade do |t|
    t.integer "weekday"
    t.integer "hour"
    t.integer "minutes"
    t.integer "executive_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["executive_id", "weekday", "hour", "minutes"], name: "index_unique_time_block", unique: true
    t.index ["executive_id"], name: "index_time_blocks_on_executive_id"
  end

end

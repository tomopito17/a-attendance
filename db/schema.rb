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

ActiveRecord::Schema.define(version: 20210613085111) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "overtime"
    t.text "task_memo"
    t.string "overwork_status"
    t.boolean "overday_check", default: false
    t.integer "overwork_sperior"
    t.string "indicater_check"
    t.integer "monthly_confirmation_approver_id"
    t.integer "monthly_confirmation_status"
    t.boolean "change", default: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.datetime "basic_time", default: "2021-07-31 23:00:00"
    t.datetime "work_time", default: "2021-07-31 22:30:00"
    t.string "affiliation"
    t.integer "employee_number"
    t.integer "uid"
    t.datetime "basic_work_time", default: "2021-07-31 23:00:00"
    t.time "designated_work_start_time", default: "2000-01-01 00:00:00"
    t.time "designated_work_end_time", default: "2000-01-01 09:00:00"
    t.boolean "superior"
    t.string "password"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "working_places", force: :cascade do |t|
    t.integer "working_place_number"
    t.string "working_place_name"
    t.string "working_place_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

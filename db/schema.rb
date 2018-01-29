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

ActiveRecord::Schema.define(version: 20180122142035) do

  create_table "day_slots", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.date     "start"
    t.integer  "semester_break_plan_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["semester_break_plan_id"], name: "index_day_slots_on_semester_break_plan_id", using: :btree
  end

  create_table "holidays", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.date     "day"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "semester_break_plan_connections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "day_slot_id"
    t.integer  "availability"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "typus"
    t.index ["day_slot_id"], name: "index_semester_break_plan_connections_on_day_slot_id", using: :btree
    t.index ["user_id"], name: "index_semester_break_plan_connections_on_user_id", using: :btree
  end

  create_table "semester_break_plans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.date     "start"
    t.date     "end"
    t.string   "name"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "free",           default: false
    t.text     "solution"
    t.boolean  "inactive",       default: false
    t.text     "fixed_solution"
    t.text     "comment"
  end

  create_table "semester_plan_connections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "time_slot_id"
    t.integer  "availability"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "typus"
    t.index ["time_slot_id"], name: "index_semester_plan_connections_on_time_slot_id", using: :btree
    t.index ["user_id"], name: "index_semester_plan_connections_on_user_id", using: :btree
  end

  create_table "semester_plans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "start"
    t.datetime "end"
    t.string   "name"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "free",                         default: false
    t.text     "solution",       limit: 65535
    t.string   "meeting_day"
    t.integer  "meeting_time"
    t.text     "fixed_solution"
    t.boolean  "inactive",       default: false
    t.text     "comment"
  end

  create_table "time_slots", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "start"
    t.integer  "end"
    t.string   "day"
    t.integer  "semester_plan_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["semester_plan_id"], name: "index_time_slots_on_semester_plan_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.boolean  "is_admin",   default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "planable",   default: true
    t.integer  "hours"
    t.datetime "last_login"
    t.boolean  "inactive",   default: false
    t.boolean  "office",     default: false
  end

  add_foreign_key "day_slots", "semester_break_plans"
  add_foreign_key "semester_break_plan_connections", "day_slots"
  add_foreign_key "semester_break_plan_connections", "users"
  add_foreign_key "semester_plan_connections", "time_slots"
  add_foreign_key "semester_plan_connections", "users"
  add_foreign_key "time_slots", "semester_plans"
end

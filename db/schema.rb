# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150912145910) do

  create_table "citations", force: :cascade do |t|
    t.string  "citation_number"
    t.date    "citation_date"
    t.date    "court_date"
    t.integer "court_id"
    t.integer "person_id"
  end

  create_table "courts", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.text   "geometry"
  end

  create_table "people", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date   "date_of_birth"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "drivers_license_number"
  end

  create_table "violations", force: :cascade do |t|
    t.string  "citation_number"
    t.string  "violation_number"
    t.string  "violation_description"
    t.boolean "warrant_status"
    t.string  "warrant_number"
    t.string  "status"
    t.date    "status_date"
    t.decimal "fine_amount",           precision: 8, scale: 2
    t.decimal "court_cost",            precision: 8, scale: 2
  end

end

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

ActiveRecord::Schema.define(version: 8) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "surname"
    t.string "email"
    t.string "crypted_password"
    t.string "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agents", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.string "password_hash"
    t.string "confirmation_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "points", default: 0
    t.boolean "trusted", default: false
    t.string "url"
  end

  create_table "agents_ips", id: :serial, force: :cascade do |t|
    t.integer "agent_id"
    t.integer "ip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ips", id: :serial, force: :cascade do |t|
    t.string "address"
    t.boolean "expired", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", id: :serial, force: :cascade do |t|
    t.string "url"
    t.string "tag"
    t.boolean "approved", default: false
    t.integer "yeses", default: 0
    t.integer "nos", default: 0
    t.integer "agent_id"
    t.integer "ip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.integer "post_id"
    t.integer "agent_id"
    t.integer "ip_id"
    t.boolean "yes", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

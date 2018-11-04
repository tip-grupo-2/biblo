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

ActiveRecord::Schema.define(version: 20181103231914) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "book_requests", force: :cascade do |t|
    t.integer  "recipient_id"
    t.integer  "requester_id"
    t.integer  "copy_id"
    t.boolean  "accepted"
    t.integer  "notification_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "book_requests", ["notification_id"], name: "index_book_requests_on_notification_id", using: :btree

  create_table "books", force: :cascade do |t|
    t.string  "isbn",        null: false
    t.string  "title",       null: false
    t.string  "author",      null: false
    t.integer "copy_id"
    t.integer "user_id"
    t.string  "picture_url"
    t.string  "description"
    t.string  "country"
  end

  create_table "copies", force: :cascade do |t|
    t.integer "user_id"
    t.integer "book_id"
    t.integer "original_owner_id"
    t.boolean "requested",         default: false
    t.boolean "reading",           default: false
    t.boolean "for_donation"
    t.boolean "in_donation",       default: true
  end

  create_table "donations", force: :cascade do |t|
    t.integer  "requester_id"
    t.integer  "giver_id"
    t.integer  "copy_id"
    t.string   "state"
    t.string   "address"
    t.integer  "notification_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "donations", ["notification_id"], name: "index_donations_on_notification_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "recipient_id"
    t.integer  "requester_id"
    t.integer  "copy_id"
    t.datetime "read_at"
    t.string   "action"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "donation_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.string   "name",                             null: false
    t.string   "address",                          null: false
    t.datetime "remember_created_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "provider"
    t.string   "uid"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "avatar"
    t.string   "phone_number"
    t.integer  "donation_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end

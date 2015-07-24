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

ActiveRecord::Schema.define(version: 20150720235412) do

  create_table "slyp_chat_messages", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "slyp_chat_id", limit: 4
    t.text     "content",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "slyp_chat_users", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "slyp_chat_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "slyp_chats", force: :cascade do |t|
    t.integer  "slyp_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_slyps", force: :cascade do |t|
    t.integer  "slyp_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",             limit: 255
    t.string   "facebook_id",       limit: 255
    t.string   "api_token",         limit: 255
    t.string   "profile_image_url", limit: 255
    t.string   "name",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "access_token",      limit: 255
    t.string   "icon_url",          limit: 255
  end

end

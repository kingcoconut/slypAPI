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

ActiveRecord::Schema.define(version: 20150824053830) do

  create_table "keywords", force: :cascade do |t|
    t.string   "keyword",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.datetime "last_read_at",           default: '2000-01-01 08:00:00'
  end

  create_table "slyp_chats", force: :cascade do |t|
    t.integer  "slyp_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "slyp_keywords", force: :cascade do |t|
    t.integer  "keyword_id", limit: 4
    t.integer  "slyp_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "slyps", force: :cascade do |t|
    t.text     "url",         limit: 255,        null: false
    t.text     "raw_url",     limit: 65535,      null: false
    t.string   "slyp_type",   limit: 7
    t.text     "title",       limit: 65535
    t.text     "author",      limit: 255
    t.date     "date"
    t.datetime "created_at",                     null: false
    t.text     "text",        limit: 4294967295
    t.text     "description", limit: 65535
    t.text     "summary",     limit: 65535
    t.text     "top_image",   limit: 65535
    t.text     "site_name",   limit: 65535
    t.boolean  "has_video"
    t.text     "video_url",   limit: 255
    t.integer  "topic_id",    limit: 4
  end

  create_table "topics", force: :cascade do |t|
    t.string   "topic",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_slyps", force: :cascade do |t|
    t.integer  "slyp_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "engaged",              default: false
    t.integer  "sender_id",  limit: 4
    t.boolean  "loved",                default: false
    t.boolean  "archived",             default: false
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
    t.integer  "sign_in_count",     limit: 4,   default: 0
    t.datetime "last_emailed_at"
  end

end

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

ActiveRecord::Schema.define(version: 20160430131233) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.integer  "question_id", null: false
    t.integer  "user_id",     null: false
    t.text     "text",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree
  add_index "answers", ["user_id", "question_id"], name: "index_answers_on_user_id_and_question_id", unique: true, using: :btree
  add_index "answers", ["user_id"], name: "index_answers_on_user_id", using: :btree

  create_table "question_categories", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ancestry"
  end

  add_index "question_categories", ["ancestry"], name: "index_question_categories_on_ancestry", using: :btree

  create_table "questions", force: :cascade do |t|
    t.integer  "question_category_id"
    t.text     "text",                 null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "questions", ["question_category_id"], name: "index_questions_on_question_category_id", using: :btree

  create_table "user_statuses", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_statuses", ["name"], name: "index_user_statuses_on_name", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                                   null: false
    t.string   "email",                                  null: false
    t.string   "encrypted_password",                     null: false
    t.integer  "user_status_id",         default: 1,     null: false
    t.boolean  "admin",                  default: false, null: false
    t.boolean  "activated",              default: false, null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "users", ["activated"], name: "index_users_on_activated", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree

end

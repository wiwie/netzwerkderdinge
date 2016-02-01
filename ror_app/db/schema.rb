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

ActiveRecord::Schema.define(version: 20160201113244) do

  create_table "assoziations", force: :cascade do |t|
    t.integer  "ding_eins_id", null: false
    t.integer  "ding_zwei_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "assoziations", ["ding_eins_id", "ding_zwei_id"], name: "assoziation_index", unique: true
  add_index "assoziations", ["ding_eins_id", "ding_zwei_id"], name: "index_assoziations_on_ding_eins_id_and_ding_zwei_id", unique: true
  add_index "assoziations", ["ding_eins_id"], name: "index_assoziations_on_ding_eins_id"
  add_index "assoziations", ["ding_zwei_id"], name: "index_assoziations_on_ding_zwei_id"

  create_table "ding_translations", force: :cascade do |t|
    t.integer  "ding_id",     null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.text     "description"
  end

  add_index "ding_translations", ["ding_id"], name: "index_ding_translations_on_ding_id"
  add_index "ding_translations", ["locale"], name: "index_ding_translations_on_locale"

  create_table "ding_typs", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dings", force: :cascade do |t|
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "description"
    t.integer  "kategorie_id"
    t.boolean  "published",    default: false
    t.integer  "indegree",     default: 0
    t.integer  "outdegree",    default: 0
    t.integer  "ding_typ_id",  default: 1
  end

  add_index "dings", ["ding_typ_id"], name: "index_dings_on_ding_typ_id"
  add_index "dings", ["kategorie_id"], name: "index_dings_on_kategorie_id"

  create_table "favorits", force: :cascade do |t|
    t.integer  "ding_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "favorits", ["ding_id", "user_id"], name: "index_favorits_on_ding_id_and_user_id", unique: true
  add_index "favorits", ["ding_id"], name: "index_favorits_on_ding_id"
  add_index "favorits", ["user_id"], name: "index_favorits_on_user_id"

  create_table "kategories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  create_table "user_assoziations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "assoziation_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "description"
    t.boolean  "published",      default: true
  end

  add_index "user_assoziations", ["assoziation_id", "user_id"], name: "index_user_assoziations_on_assoziation_id_and_user_id", unique: true
  add_index "user_assoziations", ["assoziation_id"], name: "index_user_assoziations_on_assoziation_id"
  add_index "user_assoziations", ["user_id"], name: "index_user_assoziations_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_trigger("trigger_increase_indegree", :generated => true, :compatibility => 1).
      on("assoziations").
      name("trigger_increase_indegree").
      after(:insert) do
    "UPDATE dings SET indegree = indegree + 1 WHERE id = NEW.ding_zwei_id;"
  end

  create_trigger("trigger_increase_outdegree", :generated => true, :compatibility => 1).
      on("assoziations").
      name("trigger_increase_outdegree").
      after(:insert) do
    "UPDATE dings SET outdegree = outdegree + 1 WHERE id = NEW.ding_eins_id;"
  end

  create_trigger("trigger_decrease_indegree", :generated => true, :compatibility => 1).
      on("assoziations").
      name("trigger_decrease_indegree").
      after(:delete) do
    "UPDATE dings SET indegree = indegree - 1 WHERE id = OLD.ding_zwei_id;"
  end

  create_trigger("trigger_decrease_oudegree", :generated => true, :compatibility => 1).
      on("assoziations").
      name("trigger_decrease_oudegree").
      after(:delete) do
    "UPDATE dings SET outdegree = outdegree - 1 WHERE id = OLD.ding_eins_id;"
  end

end

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

ActiveRecord::Schema.define(version: 20131115031012) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: true do |t|
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "place_id"
    t.string   "place_type"
    t.string   "country"
    t.text     "notes"
  end

  create_table "asks", force: true do |t|
    t.integer  "supplier_id"
    t.integer  "user_id"
    t.string   "request"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "real"
  end

  create_table "combos", force: true do |t|
    t.integer  "supplier_id"
    t.integer  "tag_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "combos", ["supplier_id"], name: "index_combos_on_supplier_id", using: :btree

  create_table "communications", force: true do |t|
    t.string   "means_of_interaction"
    t.string   "interaction_title"
    t.text     "notes"
    t.integer  "supplier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "email"
    t.string   "method"
    t.text     "notes"
    t.string   "type"
    t.integer  "contactable_id"
    t.string   "contactable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "dialogues", force: true do |t|
    t.boolean  "initial_select"
    t.boolean  "opener_sent"
    t.boolean  "response_received"
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.integer  "order_id"
    t.integer  "supplier_id"
    t.boolean  "further_negotiation"
    t.boolean  "won"
    t.string   "material"
    t.string   "process_name"
    t.decimal  "process_cost",        precision: 10, scale: 2
    t.string   "process_time"
    t.string   "shipping_name"
    t.decimal  "shipping_cost",       precision: 10, scale: 2
    t.decimal  "total_cost",          precision: 10, scale: 2
    t.text     "notes"
    t.string   "currency",                                     default: "dollars"
    t.boolean  "recommended",                                  default: false
    t.boolean  "informed"
  end

  add_index "dialogues", ["order_id"], name: "index_dialogues_on_order_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "model"
    t.string   "happening"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "model_id"
  end

  create_table "externals", force: true do |t|
    t.integer  "supplier_id"
    t.string   "url"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "leads", force: true do |t|
    t.string   "email"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "email_valid",      default: true
    t.boolean  "email_subscribed", default: true
  end

  create_table "locations", force: true do |t|
    t.string   "country"
    t.string   "zip"
    t.string   "location_name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "locations", ["zip"], name: "index_locations_on_zip", unique: true, using: :btree

  create_table "machines", force: true do |t|
    t.string   "manufacturer"
    t.string   "name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "orders", force: true do |t|
    t.integer  "quantity"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "user_id"
    t.string   "drawing_file_name"
    t.string   "drawing_content_type"
    t.integer  "drawing_file_size"
    t.datetime "drawing_updated_at"
    t.string   "name"
    t.string   "deadline"
    t.text     "supplier_message"
    t.text     "recommendation"
    t.text     "material_message"
    t.text     "next_steps"
    t.text     "suggested_suppliers"
    t.string   "drawing_units"
    t.string   "status",               default: "Needs work"
    t.string   "next_action_date"
    t.string   "stated_experience"
    t.string   "stated_priority"
    t.string   "stated_manufacturing"
    t.text     "notes"
  end

  create_table "owners", force: true do |t|
    t.integer  "supplier_id"
    t.integer  "machine_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "owners", ["supplier_id"], name: "index_owners_on_supplier_id", using: :btree

  create_table "reviews", force: true do |t|
    t.string   "company"
    t.string   "process"
    t.string   "part_type"
    t.boolean  "would_recommend"
    t.integer  "quality"
    t.integer  "adaptability"
    t.integer  "delivery"
    t.text     "did_well"
    t.text     "did_badly"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "displayable"
    t.integer  "supplier_id"
  end

  create_table "suppliers", force: true do |t|
    t.string   "name"
    t.string   "url_main"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.text     "description"
    t.string   "url_materials"
    t.string   "source",                        default: "manual"
    t.boolean  "profile_visible",               default: false
    t.string   "name_for_link"
    t.boolean  "claimed",                       default: false
    t.text     "suggested_description"
    t.text     "suggested_machines"
    t.text     "suggested_preferences"
    t.text     "internally_hidden_preferences"
    t.text     "suggested_services"
    t.text     "suggested_address"
    t.string   "suggested_url_main"
    t.integer  "points",                        default: 0
    t.date     "next_contact_date"
    t.string   "next_contact_content"
  end

  create_table "tags", force: true do |t|
    t.string   "name"
    t.string   "family"
    t.text     "note"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "exclusive",     default: false
    t.boolean  "visible",       default: true
    t.string   "readable"
    t.string   "name_for_link"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.boolean  "admin",                  default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "address_id"
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.boolean  "email_valid",            default: true
    t.boolean  "email_subscribed",       default: true
    t.boolean  "examiner",               default: false
    t.integer  "supplier_id"
    t.string   "phone"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  create_table "words", force: true do |t|
    t.string   "shortform"
    t.string   "longform"
    t.string   "name_for_link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "family"
  end

end

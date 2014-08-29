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

ActiveRecord::Schema.define(version: 20140829055506) do

  create_table "addresses", force: true do |t|
    t.string   "street"
    t.string   "city"
    t.string   "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "place_id"
    t.string   "place_type"
    t.text     "notes"
    t.integer  "country_id"
    t.integer  "state_id"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "communicator_id"
    t.string   "communicator_type"
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
    t.string   "first_name"
    t.string   "last_name"
    t.string   "title"
    t.string   "company"
    t.string   "linkedin_url"
    t.boolean  "email_valid",      default: true
    t.boolean  "email_subscribed", default: true
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
    t.text     "internal_notes"
    t.integer  "order_group_id"
    t.boolean  "supplier_working"
    t.text     "email_snippet"
    t.text     "close_email_body"
  end

  create_table "events", force: true do |t|
    t.string   "model"
    t.string   "happening"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "model_id"
  end

  create_table "externals", force: true do |t|
    t.string   "url"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "consumer_id"
    t.string   "consumer_type"
    t.string   "units"
  end

  create_table "filters", force: true do |t|
    t.integer  "geography_id"
    t.integer  "has_tag_id"
    t.integer  "has_not_tag_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geographies", force: true do |t|
    t.string   "level"
    t.string   "short_name"
    t.string   "long_name"
    t.string   "name_for_link"
    t.integer  "geography_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leads", force: true do |t|
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "source",               default: "manual"
    t.date     "next_contact_date"
    t.string   "next_contact_content"
    t.text     "notes"
    t.string   "priority"
    t.integer  "user_id"
    t.string   "next_contactor"
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
    t.string   "name"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.integer  "manufacturer_id"
    t.decimal  "bv_height",          precision: 6, scale: 2
    t.decimal  "bv_width",           precision: 6, scale: 2
    t.decimal  "bv_length",          precision: 6, scale: 2
    t.text     "materials_possible"
    t.string   "z_height"
    t.boolean  "profile_visible",                            default: true
    t.string   "name_for_link"
  end

  create_table "manufacturers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "profile_visible", default: true
    t.string   "name_for_link"
  end

  create_table "order_groups", force: true do |t|
    t.integer  "order_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "process"
    t.string   "material"
    t.text     "parts_snippet"
    t.text     "images_snippet"
  end

  create_table "orders", force: true do |t|
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "user_id"
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
    t.string   "status",                 default: "Needs work"
    t.string   "next_action_date"
    t.string   "stated_experience"
    t.string   "stated_priority"
    t.string   "stated_manufacturing"
    t.text     "notes"
    t.decimal  "override_average_value"
    t.string   "columns_shown",          default: "all"
    t.text     "email_snippet"
    t.integer  "stated_quantity"
    t.string   "units"
  end

  create_table "owners", force: true do |t|
    t.integer  "supplier_id"
    t.integer  "machine_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "owners", ["supplier_id"], name: "index_owners_on_supplier_id", using: :btree

  create_table "parts", force: true do |t|
    t.integer  "order_group_id"
    t.integer  "quantity"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bom_identifier"
  end

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

  create_table "search_exclusions", force: true do |t|
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_exclusions", ["domain"], name: "index_search_exclusions_on_domain", using: :btree

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

  create_table "tag_groups", force: true do |t|
    t.string   "group_name",                 null: false
    t.boolean  "exclusive",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_groups", ["group_name"], name: "index_tag_groups_on_group_name", unique: true, using: :btree

  create_table "tag_relationship_types", force: true do |t|
    t.string   "name"
    t.integer  "source_group_id"
    t.integer  "related_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_relationship_types", ["related_group_id"], name: "index_tag_relationship_types_on_related_group_id", using: :btree
  add_index "tag_relationship_types", ["source_group_id"], name: "index_tag_relationship_types_on_source_group_id", using: :btree

  create_table "tag_relationships", force: true do |t|
    t.integer  "source_tag_id",            null: false
    t.integer  "related_tag_id",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tag_relationship_type_id", null: false
  end

  add_index "tag_relationships", ["related_tag_id"], name: "index_tag_relationships_on_related_tag_id", using: :btree
  add_index "tag_relationships", ["source_tag_id"], name: "index_tag_relationships_on_source_tag_id", using: :btree
  add_index "tag_relationships", ["tag_relationship_type_id", "source_tag_id", "related_tag_id"], name: "index_tag_relationships_unique", unique: true, using: :btree

  create_table "taggable_types", force: true do |t|
    t.string   "type_name",    null: false
    t.integer  "tag_group_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggable_types", ["type_name", "tag_group_id"], name: "index_taggable_types_on_type_name_and_tag_group_id", unique: true, using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id",             null: false
    t.integer  "taggable_id",        null: false
    t.string   "taggable_type",      null: false
    t.string   "source"
    t.integer  "last_updated_by_id"
    t.integer  "confidence"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], name: "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type", using: :btree

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
    t.integer  "tag_group_id"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  add_index "tags", ["tag_group_id"], name: "index_tags_on_tag_group_id", using: :btree

  create_table "users", force: true do |t|
    t.boolean  "admin",                  default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "address_id"
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.boolean  "examiner",               default: false
    t.integer  "supplier_id"
  end

  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  create_table "web_search_items", force: true do |t|
    t.string   "query"
    t.integer  "priority"
    t.datetime "run_date"
    t.integer  "num_requested"
    t.integer  "net_new_results"
    t.integer  "suppliers_added", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "web_search_items", ["id"], name: "index_web_search_items_on_id", using: :btree

  create_table "web_search_results", force: true do |t|
    t.string   "position"
    t.string   "domain"
    t.text     "link"
    t.string   "title"
    t.text     "snippet"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "web_search_item_id"
    t.string   "action"
    t.integer  "action_taken_by_id"
    t.integer  "supplier_id"
  end

  add_index "web_search_results", ["domain"], name: "index_web_search_results_on_domain", using: :btree

end

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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130325225453) do

  create_table "addresses", :force => true do |t|
    t.string   "name"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "place_id"
    t.string   "place_type"
  end

  create_table "dialogues", :force => true do |t|
    t.boolean  "initial_select"
    t.boolean  "opener_sent"
    t.boolean  "response_received"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
    t.integer  "order_id"
    t.integer  "supplier_id"
    t.boolean  "further_negotiation"
    t.boolean  "won"
    t.string   "material"
    t.string   "process_name"
    t.decimal  "process_cost",        :precision => 10, :scale => 2
    t.string   "process_time"
    t.string   "shipping_name"
    t.decimal  "shipping_cost",       :precision => 10, :scale => 2
    t.decimal  "total_cost",          :precision => 10, :scale => 2
    t.string   "notes"
    t.string   "currency",                                           :default => "dollars"
  end

  create_table "orders", :force => true do |t|
    t.integer  "quantity"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "user_id"
    t.string   "drawing_file_name"
    t.string   "drawing_content_type"
    t.integer  "drawing_file_size"
    t.datetime "drawing_updated_at"
    t.string   "name"
    t.date     "deadline"
    t.text     "supplier_message"
    t.boolean  "is_over_without_winner"
    t.string   "recommendation"
  end

  create_table "suppliers", :force => true do |t|
    t.string   "name"
    t.string   "url_main"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.text     "blurb"
    t.string   "email"
    t.string   "phone"
    t.integer  "address_id"
    t.string   "url_materials"
    t.string   "category",      :default => "none"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.boolean  "admin"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "address_id"
    t.string   "password_digest"
    t.string   "remember_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end

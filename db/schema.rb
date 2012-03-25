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

ActiveRecord::Schema.define(:version => 20120325184431) do

  create_table "people", :force => true do |t|
    t.integer  "user_id"
    t.string   "callsign"
    t.string   "full_name"
    t.string   "status"
    t.string   "barcode"
    t.boolean  "on_site"
    t.text     "details"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "people", ["barcode"], :name => "index_people_on_barcode"
  add_index "people", ["callsign"], :name => "index_people_on_callsign"
  add_index "people", ["full_name"], :name => "index_people_on_full_name"
  add_index "people", ["user_id"], :name => "index_people_on_user_id"

  create_table "schedule_events", :force => true do |t|
    t.string   "name",                          :null => false
    t.text     "description"
    t.date     "start_date",                    :null => false
    t.date     "end_date",                      :null => false
    t.boolean  "signup_open", :default => true, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "schedule_people_positions", :id => false, :force => true do |t|
    t.integer "person_id",   :null => false
    t.integer "position_id", :null => false
  end

  add_index "schedule_people_positions", ["person_id", "position_id"], :name => "index_schedule_people_positions_on_person_id_and_position_id", :unique => true
  add_index "schedule_people_positions", ["position_id"], :name => "index_schedule_people_positions_on_position_id"

  create_table "schedule_people_slots", :id => false, :force => true do |t|
    t.integer "person_id", :null => false
    t.integer "slot_id",   :null => false
  end

  add_index "schedule_people_slots", ["person_id", "slot_id"], :name => "index_schedule_people_slots_on_person_id_and_slot_id", :unique => true
  add_index "schedule_people_slots", ["slot_id"], :name => "index_schedule_people_slots_on_slot_id"

  create_table "schedule_positions", :force => true do |t|
    t.string   "name",                                 :null => false
    t.text     "description"
    t.boolean  "new_user_eligible", :default => false, :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "schedule_shifts", :force => true do |t|
    t.string   "name",        :null => false
    t.text     "description"
    t.integer  "event_id"
    t.datetime "start_time",  :null => false
    t.datetime "end_time",    :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "schedule_shifts", ["event_id"], :name => "index_schedule_shifts_on_event_id"

  create_table "schedule_slots", :force => true do |t|
    t.integer  "shift_id",                   :null => false
    t.integer  "position_id",                :null => false
    t.integer  "min_people",  :default => 0, :null => false
    t.integer  "max_people",  :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "schedule_slots", ["position_id"], :name => "index_schedule_slots_on_position_id"
  add_index "schedule_slots", ["shift_id"], :name => "index_schedule_slots_on_shift_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "role",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_roles", ["user_id"], :name => "index_user_roles_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_view "schedule_people", "SELECT id, callsign AS name, created_at, updated_at FROM people", :force => true do |v|
    v.column :id
    v.column :name
    v.column :created_at
    v.column :updated_at
  end

end

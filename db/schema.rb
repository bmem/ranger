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

ActiveRecord::Schema.define(:version => 20121227032819) do

  create_table "credit_deltas", :force => true do |t|
    t.integer  "credit_scheme_id", :null => false
    t.string   "name"
    t.decimal  "hourly_rate",      :null => false
    t.datetime "start_time",       :null => false
    t.datetime "end_time",         :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "credit_deltas", ["credit_scheme_id"], :name => "index_credit_deltas_on_credit_scheme_id"

  create_table "credit_schemes", :force => true do |t|
    t.integer  "event_id",         :null => false
    t.string   "name",             :null => false
    t.decimal  "base_hourly_rate", :null => false
    t.text     "description"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "credit_schemes", ["event_id"], :name => "index_credit_schemes_on_event_id"

  create_table "credit_schemes_positions", :force => true do |t|
    t.integer "credit_scheme_id"
    t.integer "position_id"
  end

  add_index "credit_schemes_positions", ["credit_scheme_id", "position_id"], :name => "credit_schemes_positions_on_scheme_position", :unique => true
  add_index "credit_schemes_positions", ["position_id", "credit_scheme_id"], :name => "credit_schemes_positions_on_position_scheme"

  create_table "events", :force => true do |t|
    t.string   "name",                                      :null => false
    t.text     "description"
    t.date     "start_date",                                :null => false
    t.date     "end_date",                                  :null => false
    t.boolean  "signup_open",     :default => true,         :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "type",            :default => "BurningMan"
    t.integer  "linked_event_id"
  end

  create_table "participants", :force => true do |t|
    t.integer  "event_id",                                :null => false
    t.integer  "person_id",                               :null => false
    t.string   "name",                                    :null => false
    t.string   "full_name",                               :null => false
    t.string   "barcode"
    t.boolean  "on_site",              :default => false, :null => false
    t.string   "participation_status",                    :null => false
    t.string   "personnel_status",                        :null => false
    t.text     "details"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "participants", ["barcode"], :name => "index_participants_on_barcode"
  add_index "participants", ["event_id"], :name => "index_participants_on_event_id"
  add_index "participants", ["full_name"], :name => "index_participants_on_full_name"
  add_index "participants", ["name"], :name => "index_participants_on_name"
  add_index "participants", ["person_id"], :name => "index_participants_on_person_id"

  create_table "participants_slots", :id => false, :force => true do |t|
    t.integer "participant_id", :null => false
    t.integer "slot_id",        :null => false
  end

  add_index "participants_slots", ["participant_id", "slot_id"], :name => "index_participants_slots_on_participant_id_and_slot_id", :unique => true
  add_index "participants_slots", ["slot_id"], :name => "index_participants_slots_on_slot_id"

  create_table "people", :force => true do |t|
    t.integer  "user_id"
    t.string   "callsign",   :null => false
    t.string   "full_name",  :null => false
    t.string   "status",     :null => false
    t.string   "barcode"
    t.text     "details"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "email"
  end

  add_index "people", ["barcode"], :name => "index_people_on_barcode"
  add_index "people", ["callsign"], :name => "index_people_on_callsign"
  add_index "people", ["full_name"], :name => "index_people_on_full_name"
  add_index "people", ["user_id"], :name => "index_people_on_user_id"

  create_table "people_positions", :id => false, :force => true do |t|
    t.integer "person_id",   :null => false
    t.integer "position_id", :null => false
  end

  add_index "people_positions", ["person_id", "position_id"], :name => "index_people_positions_on_person_id_and_position_id", :unique => true
  add_index "people_positions", ["position_id"], :name => "index_people_positions_on_position_id"

  create_table "positions", :force => true do |t|
    t.string   "name",                                 :null => false
    t.text     "description"
    t.boolean  "new_user_eligible", :default => false, :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "shifts", :force => true do |t|
    t.string   "name",        :null => false
    t.text     "description"
    t.integer  "event_id"
    t.datetime "start_time",  :null => false
    t.datetime "end_time",    :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "shifts", ["event_id"], :name => "index_shifts_on_event_id"

  create_table "slots", :force => true do |t|
    t.integer  "shift_id",                   :null => false
    t.integer  "position_id",                :null => false
    t.integer  "min_people",  :default => 0, :null => false
    t.integer  "max_people",  :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "slots", ["position_id"], :name => "index_slots_on_position_id"
  add_index "slots", ["shift_id"], :name => "index_slots_on_shift_id"

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

  create_table "trainings", :force => true do |t|
    t.integer  "training_season_id"
    t.integer  "shift_id"
    t.string   "name"
    t.string   "map_link"
    t.text     "location"
    t.text     "instructions"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "trainings", ["shift_id"], :name => "index_trainings_on_shift_id"
  add_index "trainings", ["training_season_id"], :name => "index_trainings_on_training_season_id"

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

  create_table "work_logs", :force => true do |t|
    t.integer  "participant_id",                 :null => false
    t.integer  "position_id",                    :null => false
    t.integer  "event_id"
    t.integer  "shift_id"
    t.datetime "start_time",                     :null => false
    t.datetime "end_time"
    t.text     "note",           :default => "", :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "work_logs", ["event_id"], :name => "index_work_logs_on_event_id"
  add_index "work_logs", ["participant_id"], :name => "index_work_logs_on_participant_id"
  add_index "work_logs", ["position_id"], :name => "index_work_logs_on_position_id"
  add_index "work_logs", ["shift_id"], :name => "index_work_logs_on_shift_id"
  add_index "work_logs", ["start_time"], :name => "index_work_logs_on_start_time"

end

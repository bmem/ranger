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

ActiveRecord::Schema.define(:version => 20140308185549) do

  create_table "arts", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "prerequisite"
    t.text     "description"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "arts", ["name"], :name => "index_arts_on_name"

  create_table "arts_involvements", :id => false, :force => true do |t|
    t.integer "art_id",         :null => false
    t.integer "involvement_id", :null => false
  end

  add_index "arts_involvements", ["art_id"], :name => "index_arts_participants_on_art_id"
  add_index "arts_involvements", ["involvement_id", "art_id"], :name => "index_arts_participants_pair", :unique => true

  create_table "arts_trainings", :id => false, :force => true do |t|
    t.integer "art_id",      :null => false
    t.integer "training_id", :null => false
  end

  add_index "arts_trainings", ["art_id"], :name => "index_arts_trainings_on_art_id"
  add_index "arts_trainings", ["training_id", "art_id"], :name => "index_arts_trainings_on_training_id_and_art_id", :unique => true

  create_table "asset_uses", :force => true do |t|
    t.integer  "asset_id"
    t.integer  "involvement_id"
    t.integer  "event_id"
    t.datetime "checked_out"
    t.datetime "checked_in"
    t.datetime "due_in"
    t.string   "extra"
    t.text     "note"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "asset_uses", ["asset_id"], :name => "index_asset_uses_on_asset_id"
  add_index "asset_uses", ["event_id"], :name => "index_asset_uses_on_event_id"
  add_index "asset_uses", ["involvement_id"], :name => "index_asset_uses_on_involvement_id"

  create_table "assets", :force => true do |t|
    t.string   "type"
    t.integer  "event_id"
    t.string   "name"
    t.string   "designation"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "assets", ["event_id", "type", "name"], :name => "index_assets_on_event_id_and_type_and_name", :unique => true

  create_table "attendees", :force => true do |t|
    t.integer  "involvement_id",                        :null => false
    t.integer  "slot_id",                               :null => false
    t.string   "status",         :default => "planned", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attendees", ["involvement_id", "slot_id"], :name => "index_participants_slots_pair", :unique => true
  add_index "attendees", ["slot_id"], :name => "index_participants_slots_on_slot_id"

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes", :limit => 20971520
    t.integer  "version",                             :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "callsign_assignments", :force => true do |t|
    t.integer  "callsign_id",                        :null => false
    t.integer  "person_id",                          :null => false
    t.date     "start_date",                         :null => false
    t.date     "end_date"
    t.boolean  "primary_callsign", :default => true, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "callsign_assignments", ["callsign_id"], :name => "index_callsign_assignments_on_callsign_id"
  add_index "callsign_assignments", ["person_id"], :name => "index_callsign_assignments_on_person_id"

  create_table "callsigns", :force => true do |t|
    t.string   "name",                       :null => false
    t.string   "status",                     :null => false
    t.text     "note",       :default => "", :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "slug"
  end

  add_index "callsigns", ["name"], :name => "index_callsigns_on_name", :unique => true
  add_index "callsigns", ["slug"], :name => "index_callsigns_on_slug", :unique => true

  create_table "credit_deltas", :force => true do |t|
    t.integer  "credit_scheme_id",                                :null => false
    t.string   "name"
    t.decimal  "hourly_rate",      :precision => 10, :scale => 2, :null => false
    t.datetime "start_time",                                      :null => false
    t.datetime "end_time",                                        :null => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "credit_deltas", ["credit_scheme_id"], :name => "index_credit_deltas_on_credit_scheme_id"

  create_table "credit_schemes", :force => true do |t|
    t.integer  "event_id",                                        :null => false
    t.string   "name",                                            :null => false
    t.decimal  "base_hourly_rate", :precision => 10, :scale => 2, :null => false
    t.text     "description"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
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
    t.string   "slug"
  end

  add_index "events", ["slug"], :name => "index_events_on_slug", :unique => true

  create_table "involvements", :force => true do |t|
    t.integer  "event_id",                              :null => false
    t.integer  "person_id",                             :null => false
    t.string   "name",                                  :null => false
    t.string   "barcode"
    t.boolean  "on_site",            :default => false, :null => false
    t.string   "involvement_status",                    :null => false
    t.string   "personnel_status",                      :null => false
    t.text     "details"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "involvements", ["barcode"], :name => "index_participants_on_barcode"
  add_index "involvements", ["event_id"], :name => "index_participants_on_event_id"
  add_index "involvements", ["name"], :name => "index_participants_on_name"
  add_index "involvements", ["person_id"], :name => "index_participants_on_person_id"

  create_table "mailing_addresses", :force => true do |t|
    t.string   "extra_address"
    t.string   "street_address"
    t.string   "post_office_box"
    t.string   "locality"
    t.string   "region"
    t.string   "postal_code"
    t.string   "country_name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "mentors", :force => true do |t|
    t.integer  "event_id"
    t.integer  "mentorship_id"
    t.integer  "involvement_id"
    t.string   "vote"
    t.text     "note"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "mentors", ["event_id"], :name => "index_mentors_on_event_id"
  add_index "mentors", ["involvement_id"], :name => "index_mentors_on_involvement_id"
  add_index "mentors", ["mentorship_id"], :name => "index_mentors_on_mentorship_id"

  create_table "mentorships", :force => true do |t|
    t.integer  "event_id"
    t.integer  "shift_id"
    t.integer  "mentee_id"
    t.string   "outcome"
    t.text     "note"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "mentorships", ["event_id"], :name => "index_mentorships_on_event_id"
  add_index "mentorships", ["mentee_id"], :name => "index_mentorships_on_mentee_id"
  add_index "mentorships", ["shift_id"], :name => "index_mentorships_on_shift_id"

  create_table "message_receipts", :force => true do |t|
    t.integer  "message_id",                      :null => false
    t.integer  "recipient_id",                    :null => false
    t.boolean  "delivered",    :default => false, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.boolean  "deleted",      :default => false, :null => false
  end

  add_index "message_receipts", ["message_id"], :name => "index_message_receipts_on_message_id"
  add_index "message_receipts", ["recipient_id"], :name => "index_message_receipts_on_recipient_id"

  create_table "messages", :force => true do |t|
    t.string   "type"
    t.string   "title"
    t.string   "from"
    t.string   "to"
    t.datetime "expires"
    t.integer  "sender_id"
    t.text     "body",       :limit => 1048576
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"

  create_table "people", :force => true do |t|
    t.string   "display_name", :null => false
    t.string   "full_name",    :null => false
    t.string   "status",       :null => false
    t.string   "barcode"
    t.text     "details"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "email"
  end

  add_index "people", ["barcode"], :name => "index_people_on_barcode"
  add_index "people", ["display_name"], :name => "index_people_on_callsign"
  add_index "people", ["full_name"], :name => "index_people_on_full_name"

  create_table "people_positions", :id => false, :force => true do |t|
    t.integer "person_id",   :null => false
    t.integer "position_id", :null => false
  end

  add_index "people_positions", ["person_id", "position_id"], :name => "index_people_positions_on_person_id_and_position_id", :unique => true
  add_index "people_positions", ["position_id"], :name => "index_people_positions_on_position_id"

  create_table "positions", :force => true do |t|
    t.string   "name",                                         :null => false
    t.text     "description"
    t.boolean  "new_user_eligible",         :default => false, :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "team_id"
    t.boolean  "all_team_members_eligible", :default => false
    t.string   "slug"
  end

  add_index "positions", ["slug"], :name => "index_positions_on_slug", :unique => true

  create_table "profiles", :force => true do |t|
    t.integer  "person_id"
    t.string   "full_name"
    t.string   "nicknames"
    t.string   "email"
    t.string   "phone_numbers"
    t.integer  "mailing_address_id"
    t.text     "contact_note"
    t.string   "gender"
    t.date     "birth_date"
    t.string   "shirt_size"
    t.string   "shirt_style"
    t.string   "years_at_burning_man"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "profiles", ["mailing_address_id"], :name => "index_profiles_on_mailing_address_id"
  add_index "profiles", ["person_id"], :name => "index_profiles_on_person_id"

  create_table "reports", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.string   "name"
    t.integer  "num_results"
    t.text     "note"
    t.text     "report_object",       :limit => 20971520
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.text     "readable_parameters", :limit => 131072
  end

  add_index "reports", ["event_id"], :name => "index_reports_on_event_id"
  add_index "reports", ["user_id"], :name => "index_reports_on_user_id"

  create_table "shift_templates", :force => true do |t|
    t.string   "title",                                  :null => false
    t.string   "name"
    t.text     "description"
    t.integer  "start_hour",   :default => 0,            :null => false
    t.integer  "start_minute", :default => 0,            :null => false
    t.integer  "end_hour",     :default => 0,            :null => false
    t.integer  "end_minute",   :default => 0,            :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "event_type",   :default => "BurningMan", :null => false
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

  create_table "slot_templates", :force => true do |t|
    t.integer  "shift_template_id",                :null => false
    t.integer  "position_id",                      :null => false
    t.integer  "min_people",        :default => 0, :null => false
    t.integer  "max_people",        :default => 0, :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "slot_templates", ["shift_template_id"], :name => "index_slot_templates_on_shift_template_id"

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

  create_table "team_managers", :id => false, :force => true do |t|
    t.integer "team_id",   :null => false
    t.integer "person_id", :null => false
  end

  add_index "team_managers", ["person_id"], :name => "index_team_managers_on_person_id"
  add_index "team_managers", ["team_id", "person_id"], :name => "index_team_managers_on_team_id_and_person_id", :unique => true

  create_table "team_members", :id => false, :force => true do |t|
    t.integer "team_id",   :null => false
    t.integer "person_id", :null => false
  end

  add_index "team_members", ["person_id"], :name => "index_team_members_on_person_id"
  add_index "team_members", ["team_id", "person_id"], :name => "index_team_members_on_team_id_and_person_id", :unique => true

  create_table "teams", :force => true do |t|
    t.string   "slug",        :null => false
    t.string   "name",        :null => false
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "teams", ["slug"], :name => "index_teams_on_slug", :unique => true

  create_table "trainings", :force => true do |t|
    t.integer  "shift_id"
    t.string   "map_link"
    t.text     "location"
    t.text     "instructions"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "trainings", ["shift_id"], :name => "index_trainings_on_shift_id"

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "role",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_roles", ["user_id"], :name => "index_user_roles_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "disabled",               :default => false, :null => false
    t.string   "disabled_message"
    t.integer  "person_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["person_id"], :name => "index_users_on_person_id", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "work_logs", :force => true do |t|
    t.integer  "involvement_id",                 :null => false
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
  add_index "work_logs", ["involvement_id"], :name => "index_work_logs_on_participant_id"
  add_index "work_logs", ["position_id"], :name => "index_work_logs_on_position_id"
  add_index "work_logs", ["shift_id"], :name => "index_work_logs_on_shift_id"
  add_index "work_logs", ["start_time"], :name => "index_work_logs_on_start_time"

end

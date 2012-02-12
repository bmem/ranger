# This migration comes from schedule (originally 20111225230542)
class CreateScheduleSlots < ActiveRecord::Migration
  def change
    create_table :schedule_slots do |t|
      t.references :shift, :null => false
      t.references :position, :null => false
      t.integer :min_people, :null => false, :default => 0
      t.integer :max_people, :null => false, :default => 0

      t.timestamps
    end
    add_index :schedule_slots, :shift_id
    add_index :schedule_slots, :position_id

    create_table :schedule_people_slots, :id => false do |t|
      t.references :person, :null => false
      t.references :slot, :null => false
    end
    add_index :schedule_people_slots, [:person_id, :slot_id], :unique => true
    add_index :schedule_people_slots, :slot_id
  end
end

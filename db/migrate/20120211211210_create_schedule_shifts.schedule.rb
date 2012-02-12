# This migration comes from schedule (originally 20111225225953)
class CreateScheduleShifts < ActiveRecord::Migration
  def change
    create_table :schedule_shifts do |t|
      t.string :name, :null => false
      t.text :description
      t.references :event
      t.datetime :start_time, :null => false
      t.datetime :end_time, :null => false

      t.timestamps
    end
    add_index :schedule_shifts, :event_id
  end
end

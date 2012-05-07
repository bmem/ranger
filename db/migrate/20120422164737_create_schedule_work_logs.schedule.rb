# This migration comes from schedule (originally 20120407224910)
class CreateScheduleWorkLogs < ActiveRecord::Migration
  def change
    create_table :schedule_work_logs do |t|
      t.references :person,   :null => false
      t.references :position, :null => false
      t.references :event
      t.references :shift
      t.datetime :start_time, :null => false
      t.datetime :end_time
      t.text :note,           :null => false, :default => ''

      t.timestamps
    end
    add_index :schedule_work_logs, :person_id
    add_index :schedule_work_logs, :position_id
    add_index :schedule_work_logs, :event_id
    add_index :schedule_work_logs, :shift_id
    add_index :schedule_work_logs, :start_time
  end
end

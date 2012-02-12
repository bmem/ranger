# This migration comes from schedule (originally 20111225223244)
class CreateScheduleEvents < ActiveRecord::Migration
  def change
    create_table :schedule_events do |t|
      t.string :name, :null => false
      t.text :description
      t.date :start_date, :null => false
      t.date :end_date, :null => false
      t.boolean :signup_open, :null => false, :default => true

      t.timestamps
    end
  end
end

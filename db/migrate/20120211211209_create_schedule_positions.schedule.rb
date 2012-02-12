# This migration comes from schedule (originally 20111225225043)
class CreateSchedulePositions < ActiveRecord::Migration
  def change
    create_table :schedule_positions do |t|
      t.string :name, :null => false
      t.text :description
      t.boolean :new_user_eligible, :null => false, :default => false

      t.timestamps
    end

    create_table :schedule_people_positions, :id => false do |t|
      t.references :person, :null => false
      t.references :position, :null => false
    end
    add_index :schedule_people_positions,
        [:person_id, :position_id], :unique => true
    add_index :schedule_people_positions, [:position_id]
  end
end

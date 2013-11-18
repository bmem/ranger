class CreateCallsignAssignments < ActiveRecord::Migration
  def change
    create_table :callsign_assignments do |t|
      t.references :callsign, null: false
      t.references :person, null: false
      t.date :start_date, null: false
      t.date :end_date
      t.boolean :primary_callsign, null: false, default: true

      t.timestamps
    end
    add_index :callsign_assignments, :callsign_id
    add_index :callsign_assignments, :person_id
  end
end

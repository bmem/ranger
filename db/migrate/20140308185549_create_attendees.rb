class CreateAttendees < ActiveRecord::Migration
  def up
    rename_table :involvements_slots, :attendees
    add_column :attendees, :id, :primary_key
    change_table :attendees do |t|
      t.string :status, null: false, default: 'planned'
      t.timestamps
    end
    Attendee.where('created_at IS NULL').each do |attendee|
      attendee.created_at = Time.zone.now
      attendee.save!
    end
  end

  def down
    change_table :attendees do |t|
      t.remove :status
      t.remove_timestamps
      t.remove :id
    end
    rename_table :attendees, :involvements_slots
  end
end

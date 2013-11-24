class CreateMentorships < ActiveRecord::Migration
  def change
    create_table :mentorships do |t|
      t.references :event
      t.references :shift
      t.references :mentee
      t.string :outcome
      t.text :note

      t.timestamps
    end
    add_index :mentorships, :event_id
    add_index :mentorships, :shift_id
    add_index :mentorships, :mentee_id
  end
end

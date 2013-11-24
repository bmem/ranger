class CreateMentors < ActiveRecord::Migration
  def change
    create_table :mentors do |t|
      t.references :event
      t.references :mentorship
      t.references :involvement
      t.string :vote
      t.text :note

      t.timestamps
    end
    add_index :mentors, :event_id
    add_index :mentors, :mentorship_id
    add_index :mentors, :involvement_id
  end
end

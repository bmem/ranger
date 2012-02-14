class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :callsign
      t.string :full_name
      t.string :status
      t.string :barcode
      t.boolean :on_site
      t.text :details

      t.timestamps
    end
    add_index :people, :callsign
    add_index :people, :barcode
    add_index :people, :full_name

    drop_table :schedule_people
    cols = "id, callsign AS name, created_at, updated_at"
    create_view :schedule_people, "SELECT #{cols} FROM people" do |v|
      v.column :id
      v.column :name
      v.column :created_at
      v.column :updated_at
    end
  end
end

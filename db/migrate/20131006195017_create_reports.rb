class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.references :user
      t.references :event
      t.string :name
      t.integer :num_results
      t.text :note
      t.text :report_object

      t.timestamps
    end
    add_index :reports, :user_id
    add_index :reports, :event_id
  end
end

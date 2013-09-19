class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string :type
      t.references :event
      t.string :name
      t.string :designation
      t.text :description

      t.timestamps
    end
    add_index :assets, [:event_id, :type, :name], unique: true
  end
end

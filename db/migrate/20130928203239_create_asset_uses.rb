class CreateAssetUses < ActiveRecord::Migration
  def change
    create_table :asset_uses do |t|
      t.references :asset
      t.references :involvement
      t.references :event
      t.datetime :checked_out
      t.datetime :checked_in
      t.datetime :due_in
      t.string :extra
      t.text :note

      t.timestamps
    end
    add_index :asset_uses, :asset_id
    add_index :asset_uses, :involvement_id
    add_index :asset_uses, :event_id
  end
end

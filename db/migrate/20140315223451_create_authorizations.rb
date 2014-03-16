class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.string :type
      t.references :event
      t.references :involvement
      t.references :user

      t.timestamps
    end
    add_index :authorizations, [:type, :event_id, :involvement_id], unique: true
    add_index :authorizations, :event_id
    add_index :authorizations, :involvement_id
  end
end

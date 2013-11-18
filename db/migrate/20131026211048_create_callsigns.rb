class CreateCallsigns < ActiveRecord::Migration
  def change
    create_table :callsigns do |t|
      t.string :name, null: false
      t.string :status, null: false
      t.text :note, null: false, default: ''

      t.timestamps
    end

    add_index :callsigns, :name, unique: true
  end
end

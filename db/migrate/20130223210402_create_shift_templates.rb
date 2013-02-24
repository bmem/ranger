class CreateShiftTemplates < ActiveRecord::Migration
  def change
    create_table :shift_templates do |t|
      t.string :title, :null => false
      t.string :name
      t.text :description
      t.integer :start_hour, :default => 0, :null => false
      t.integer :start_minute, :default => 0, :null => false
      t.integer :end_hour, :default => 0, :null => false
      t.integer :end_minute, :default => 0, :null => false

      t.timestamps
    end
  end
end

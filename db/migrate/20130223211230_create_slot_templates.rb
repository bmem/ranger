class CreateSlotTemplates < ActiveRecord::Migration
  def change
    create_table :slot_templates do |t|
      t.references :shift_template, :null => false
      t.references :position, :null => false
      t.integer :min_people, :default => 0, :null => false
      t.integer :max_people, :default => 0, :null => false

      t.timestamps
    end
    add_index :slot_templates, :shift_template_id
  end
end

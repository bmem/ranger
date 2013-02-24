class AddEventTypeToShiftTemplates < ActiveRecord::Migration
  def change
    add_column :shift_templates, :event_type, :string, :default => 'BurningMan', :null => false
  end
end

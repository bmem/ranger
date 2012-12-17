class AddTypeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :type, :string, :allow_nil => false, :default => 'BurningMan'
    add_column :events, :linked_event_id, :integer
  end
end

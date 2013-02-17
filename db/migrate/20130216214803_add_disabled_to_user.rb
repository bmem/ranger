class AddDisabledToUser < ActiveRecord::Migration
  def change
    add_column :users, :disabled, :boolean, :default => false, :null => false
    add_column :users, :disabled_message, :string
  end
end

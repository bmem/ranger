class RenameCallsignToDisplayName < ActiveRecord::Migration
  def up
    rename_column :people, :callsign, :display_name
  end

  def down
    rename_column :people, :display_name, :callsign
  end
end

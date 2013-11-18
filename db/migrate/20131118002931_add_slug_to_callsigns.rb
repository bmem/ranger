class AddSlugToCallsigns < ActiveRecord::Migration
  def change
    add_column :callsigns, :slug, :string
    add_index :callsigns, :slug, unique: true
    Callsign.find_each(&:save)
  end
end

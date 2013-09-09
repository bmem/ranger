class AddSlugToEvents < ActiveRecord::Migration
  def change
    add_column :events, :slug, :string
    add_index :events, :slug, unique: true

    Event.find_each(&:save)
  end
end

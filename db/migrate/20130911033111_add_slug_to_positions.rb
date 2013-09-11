class AddSlugToPositions < ActiveRecord::Migration
  def change
    add_column :positions, :slug, :string
    add_index :positions, :slug, unique: true

    Position.find_each(&:save)
  end
end

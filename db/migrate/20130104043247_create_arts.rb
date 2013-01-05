class CreateArts < ActiveRecord::Migration
  def change
    create_table :arts do |t|
      t.string :name, :null => false
      t.string :prerequisite
      t.text :description

      t.timestamps
    end
    add_index :arts, :name
  end
end

class CreateTrainings < ActiveRecord::Migration
  def change
    create_table :trainings do |t|
      t.references :shift
      t.string :map_link
      t.text :location
      t.text :instructions

      t.timestamps
    end
    add_index :trainings, :shift_id
  end
end

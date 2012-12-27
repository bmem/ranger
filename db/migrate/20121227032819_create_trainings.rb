class CreateTrainings < ActiveRecord::Migration
  def change
    create_table :trainings do |t|
      t.references :training_season
      t.references :shift
      t.string :name
      t.string :map_link
      t.text :location
      t.text :instructions

      t.timestamps
    end
    add_index :trainings, :training_season_id
    add_index :trainings, :shift_id
  end
end

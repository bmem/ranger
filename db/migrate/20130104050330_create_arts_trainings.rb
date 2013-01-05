class CreateArtsTrainings < ActiveRecord::Migration
  def up
    create_table :arts_trainings, :id => false do |t|
      t.references :art, :null => false
      t.references :training, :null => false
    end
    add_index :arts_trainings, :art_id
    add_index :arts_trainings, [:training_id, :art_id], :unique => true

    create_table :arts_participants, :id => false do |t|
      t.references :art, :null => false
      t.references :participant, :null => false
    end
    add_index :arts_participants, :art_id
    add_index :arts_participants, [:participant_id, :art_id], :unique => true
  end

  def down
    drop_table :arts_participants
    drop_table :arts_trainings
  end
end

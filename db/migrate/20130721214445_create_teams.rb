class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :slug, :null => false
      t.string :name, :null => false
      t.text :description

      t.timestamps
    end
    add_index :teams, :slug, unique: true

    create_table :team_members, :id => false do |t|
      t.references :team, :null => false
      t.references :person, :null => false
    end
    add_index :team_members, [:team_id, :person_id], unique: true
    add_index :team_members, :person_id

    create_table :team_managers, :id => false do |t|
      t.references :team, :null => false
      t.references :person, :null => false
    end
    add_index :team_managers, [:team_id, :person_id], unique: true
    add_index :team_managers, :person_id

    change_table :positions do |t|
      t.references :team
      t.boolean :all_team_members_eligible, default: false
    end
  end
end

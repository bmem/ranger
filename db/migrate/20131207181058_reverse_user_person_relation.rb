class ReverseUserPersonRelation < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.references :person
    end
    add_index :users, :person_id, unique: true

    User.all.each do |user|
      person = Person.find_by_user_id(user.id)
      user.person_id = person.id
      user.save!
    end

    remove_column :people, :user_id
  end

  def down
    unless column_exists? :people, :user_id
      change_table :people do |t|
        t.references :user
      end
      add_index :people, :user_id, unique: true

      Person.all.each do |person|
        user = User.find_by_person_id(person.id)
        person.user_id = user.id
        person.save!
      end
    end

    remove_column :users, :person_id
  end
end

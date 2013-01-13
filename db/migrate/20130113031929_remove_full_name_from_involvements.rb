class RemoveFullNameFromInvolvements < ActiveRecord::Migration
  def up
    remove_column :involvements, :full_name
  end

  def down
    add_column :involvements, :full_name
    Involvement.each do |i|
      i.full_name = i.person.full_name
    end
  end
end

class AddEmailToPerson < ActiveRecord::Migration
  def change
    add_column :people, :email, :string
    Person.reset_column_information
    Person.all.each {|p| p.update_attribute :email, p.details[:email]}
  end
end

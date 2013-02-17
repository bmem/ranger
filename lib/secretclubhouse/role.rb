module SecretClubhouse
  class Role < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'role'
    has_and_belongs_to_many :people, :join_table => 'person_role'
  end
end

module SecretClubhouse
  class Position < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'position'
    self.target ::Position, :name, :new_user_eligible

    def name
      title
    end
  end
end

module SecretClubhouse
  class Position < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'position'
    self.target ::Position, :name, :new_user_eligible

    # ID constants
    TRAINING = 13
    TRAINER = 23

    def name
      title.strip
    end
  end
end

module SecretClubhouse
  class TraineeStatus < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'trainee_status'
    belongs_to :slot
    belongs_to :person
  end
end

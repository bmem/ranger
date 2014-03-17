module SecretClubhouse
  class Ticket < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'ticket'

    belongs_to :person
  end
end

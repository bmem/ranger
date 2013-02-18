module SecretClubhouse
  class Language < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'person_language'

    belongs_to :person
  end
end

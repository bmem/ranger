module SecretClubhouse
  class AssetPerson < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'asset_person'
    target ::AssetUse, :checked_out, :checked_in, :due_in, :extra

    EXTRAS = {1 => 'Shoulder Mic', 2 => 'Headset', 3 => 'Helicopter Headset',
      4 => 'Sur Kit'}

    def due_in
      checked_in.try {|d| d} || checked_out + 30.days
    end

    def extra
      EXTRAS[attachment_id]
    end
  end
end

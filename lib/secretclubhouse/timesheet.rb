module SecretClubhouse
  class Timesheet < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'timesheet'
    self.target ::WorkLog, :position_id, :start_time, :end_time

    def start_time
      on_duty
    end

    def end_time
      off_duty
    end
  end
end

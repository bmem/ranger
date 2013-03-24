module SecretClubhouse
  class Timesheet < ActiveRecord::Base
    include BaseRecord
    include TimeZoneAdjusting
    self.table_name = 'timesheet'
    self.target ::WorkLog, :position_id, :start_time, :end_time

    def start_time
      adjust_time on_duty
    end

    def end_time
      adjust_time off_duty
    end
  end
end

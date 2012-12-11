module SecretClubhouse
  class Timesheet < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'timesheet'
    self.target ::WorkLog, :position_id, :start_time, :end_time

    def start_time
      adjust_time on_duty
    end

    def end_time
      adjust_time off_duty
    end

    def adjust_time(datetime)
      # clubhouse stored "local" dates in UTC
      # Burning Man happens during DST, manual adjustments in January
      delta = datetime.month.in?(4..10) ? 7.hours : 8.hours
      Time.zone.at(datetime.to_i + delta)
    end
  end
end

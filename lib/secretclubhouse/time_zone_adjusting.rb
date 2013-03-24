module SecretClubhouse
  module TimeZoneAdjusting
    def adjust_time(datetime)
      # clubhouse stored "local" dates in UTC
      # Burning Man happens during DST, manual adjustments in January
      delta = datetime.month.in?(4..10) ? 7.hours : 8.hours
      Time.zone.at(datetime.to_i + delta)
    end
  end
end

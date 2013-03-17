module TimeHelper
  def distance_of_time_hours_minutes(start_time, end_time)
    end_time ||= Time.now
    seconds = end_time.to_time - start_time.to_time
    hoursminutes = (seconds / 60).divmod(60)
    format_hours_minutes(hoursminutes[0], hoursminutes[1].round, false)
  end

  def format_hours_minutes(hours, minutes, zero_pad_hours=true)
    format(zero_pad_hours ? '%02d:%02d' : '%d:%02d', hours, minutes)
  end
end

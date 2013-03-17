module TimeHelper
  def distance_of_time_hours_minutes(start_time, end_time)
    end_time ||= Time.now
    seconds = end_time.to_time - start_time.to_time
    hm = hours_minutes(seconds)
    format_hours_minutes(hm[0], hm[1], false)
  end

  def format_hours_minutes(hours, minutes, zero_pad_hours=true)
    format(zero_pad_hours ? '%02d:%02d' : '%d:%02d', hours, minutes)
  end

  def format_seconds_as_hours_minutes(seconds)
    hm = hours_minutes(seconds)
    format_hours_minutes(hm[0], hm[1], false)
  end

  # Computes [hours, minutes] from a number of seconds.
  def hours_minutes(seconds)
    # convert seconds to minutes, divmod to get hours and remainder
    seconds.fdiv(60).round.divmod(60)
  end
end

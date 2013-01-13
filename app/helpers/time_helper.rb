module TimeHelper
  def distance_of_time_hours_minutes(start_time, end_time)
    seconds = end_time.to_time - start_time.to_time
    hoursminutes = (seconds / 60).divmod(60)
    format('%d:%02d', hoursminutes[0], hoursminutes[1].round)
  end
end

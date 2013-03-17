# A switch which changes binary state if a checked date is a different day than
# the previously checked date.
class DateToggle
  def initialize(initial = Time.zone.at(0))
    @cur_day = initial.strftime('%y-%m-%d')
    @cur_state = false
  end

  def check(date)
    day = date.strftime('%y-%m-%d')
    unless day == @cur_day
      @cur_state = !@cur_state
      @cur_day = day
    end
    @cur_state
  end

  def state
    @cur_state
  end
end

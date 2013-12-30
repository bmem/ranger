require 'test_helper'

class ShiftTest < ActiveSupport::TestCase
  test "validates presence" do
    assert Shift.new.invalid?, "Empty shift was valid"
    event = events(:one)
    shift = Shift.new name: 'A shift',
      start_time: 1.hour.ago.to_datetime, end_time: 1.hour.from_now.to_datetime
    shift.event = event
    assert shift.valid?, "Full shift was invalid"
    shift.name = nil
    assert shift.invalid?, "Nil name was valid"
    shift.name = ''
    assert shift.invalid?, "Empty name was valid"
    shift.name = 'X'
    assert shift.valid?, "With name was invalid"
    shift.start_time = nil
    assert shift.invalid?, "Nil start date was valid"
    shift.start_time = DateTime.new 2011, 1, 1, 12, 34
    assert shift.valid?, "Start date was invalid"
    shift.end_time = nil
    assert shift.invalid?, "Nil end date was valid"
    shift.end_time = DateTime.new 2011, 12, 31, 21, 45
    assert shift.valid?, "End date was invalid"
  end

  test "date order" do
    now = DateTime.now
    event = events(:one)
    shift = event.shifts.build name: 'A shift', start_time: now, end_time: now
    assert shift.valid?, "Same start and end were invalid"
    shift.end_time = 1.hour.ago.to_datetime
    assert shift.invalid?, "End before start was valid"
  end
end

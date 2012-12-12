require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test "validates presence" do
    assert !Event.new.valid?, "Empty event was valid"
    event = Event.new :name => 'An event',
      :start_date => Date.today, :end_date => Date.tomorrow
    assert event.valid?, "Full event was invalid"
    event.name = nil
    assert event.invalid?, "Nil name was valid"
    event.name = ''
    assert event.invalid?, "Empty name was valid"
    event.name = 'X'
    assert event.valid?, "With name was invalid"
    event.start_date = nil
    assert event.invalid?, "Nil start date was valid"
    event.start_date = Date.new 2011, 1, 1
    assert event.valid?, "Start date was invalid"
    event.end_date = nil
    assert event.invalid?, "Nil end date was valid"
    event.end_date = Date.new 2011, 12, 31
    assert event.valid?, "End date was invalid"
  end

  test "date order" do
    event = Event.new :name => 'An event',
      :start_date => Date.today, :end_date => Date.tomorrow
    assert event.valid?, "Full event was invalid"
    event.end_date = Date.today
    assert event.valid?, "Start and end on same day was invalid"
    event.start_date = Date.tomorrow
    event.end_date = Date.yesterday
    assert event.invalid?, "End date before start date was valid"
  end
end

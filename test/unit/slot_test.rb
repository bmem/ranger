require 'test_helper'

class SlotTest < ActiveSupport::TestCase
  test "validates presence" do
    assert Slot.new.invalid?, "Empty slot was valid"
    shift = Shift.new :name => 'Day',
      :start_time => 1.hour.ago, :end_time => 1.hour.from_now
    shift = shifts(:one)
    position = positions(:dirt)
    Slot.new.tap do |slot|
      slot.shift = shift
      assert slot.invalid?, "Just shift was valid"
    end
    Slot.new.tap do |slot|
      slot.position = position
      assert slot.invalid?, "Just position was valid"
    end
    Slot.new.tap do |slot|
      slot.shift = shift
      slot.position = position
      assert slot.valid?, "Full slot was invalid"
    end
  end

  test "validates numericality" do
    shift = Shift.new :name => 'Day',
      :start_time => 1.hour.ago, :end_time => 1.hour.from_now
    shift = shifts(:one)
    position = positions(:dirt)
    slot = shift.slots.build min_people: 0, max_people: 0
    slot.position = position
    assert slot.valid?, "Full slot was invalid #{slot.errors.full_messages}"
    slot.min_people = nil
    assert slot.invalid?, "Nil min people was valid"
    slot.min_people = 0
    slot.max_people = nil
    assert slot.invalid?, "Nil max people was valid"
    slot.max_people = 0
    slot.min_people = 1.5
    assert slot.invalid?, "Float min people was valid"
    slot.min_people = 0
    slot.max_people = 1.5
    assert slot.invalid?, "Float max people was valid"
    slot.max_people = 0
    slot.min_people = "10"
    slot.max_people = "20"
    assert slot.valid?, "String numbers were invalid"
    slot.min_people = -10
    assert slot.invalid?, "Negative min people was valid"
    slot.min_people = 0
    slot.max_people = -1;
    assert slot.invalid?, "Negative max people was valid"
    slot.max_people = 0
  end
end

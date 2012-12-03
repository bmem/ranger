require 'test_helper'

class SlotTest < ActiveSupport::TestCase
  test "validates presence" do
    assert Slot.new.invalid?, "Empty slot was valid"
    shift = Shift.new :name => 'Day',
      :start_time => 1.hour.ago, :end_time => 1.hour.from_now
    shift = shifts(:one)
    position = Position.new :name => 'Manager'
    position = positions(:one)
    assert Slot.new(:shift => shift).invalid?, "Just shift was valid"
    assert Slot.new(:position => position).invalid?, "Just position was valid"
    assert Slot.new(:shift => shift, :position => position).valid?,
      "Full slot was invalid"
  end

  test "validates numericality" do
    shift = Shift.new :name => 'Day',
      :start_time => 1.hour.ago, :end_time => 1.hour.from_now
    shift = shifts(:one)
    position = Position.new :name => 'Manager'
    position = positions(:one)
    slot = Slot.new(:shift => shift, :position => position,
      :min_people => 0, :max_people => 0)
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

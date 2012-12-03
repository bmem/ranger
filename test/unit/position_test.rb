require 'test_helper'

class PositionTest < ActiveSupport::TestCase
  test "validates presence" do
    assert Position.new.invalid?, "Empty position was valid"
    assert Position.new(:name => "Manager").valid?, "Named position was invalid"
    assert Position.new(:name => "").invalid?, "Empty name was valid"
    assert Position.new(:name => " \n ").invalid?, "Whitespace name was valid"
  end

  test "new user eligible default" do
    assert !Position.new.new_user_eligible?
  end
end

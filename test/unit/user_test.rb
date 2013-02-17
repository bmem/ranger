require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "email is required" do
    assert User.new.invalid?, "Empty user was valid"
    u1 = users(:adminuser)
    u1.email = ''
    assert u1.invalid?, "Empty email was valid"
  end

  test "email is unique" do
    u1 = users(:adminuser)
    u2 = User.new :email => u1.email
    assert u2.invalid?, "Duplicate email was valid"
    u2.email = u2.email.upcase
    assert u2.invalid?, "Upper case duplicate was valid"
  end

  test "disabled user cannot authenticate" do
    u1 = users(:normaluser1)
    u1.disabled = true
    assert !u1.active_for_authentication?, "disabled user was active"
    assert_not_nil u1.inactive_message
    u1.disabled_message = 'User is deceased'
    assert_equal 'User is deceased', u1.inactive_message
  end
end

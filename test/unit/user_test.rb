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
end

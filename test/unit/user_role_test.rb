require 'test_helper'

class UserRoleTest < ActiveSupport::TestCase
  test "can add valid role" do
    ur = UserRole.new :user_id => 1, :role => 'admin'
    assert ur.valid?, ur.errors.to_hash
  end

  test "can't add invalid role" do
    ur = UserRole.new :user_id => 1, :role => 'bogus'
    assert !ur.valid?
  end
end

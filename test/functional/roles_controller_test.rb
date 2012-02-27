require 'test_helper'

class RolesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show by role" do
    get :show, :id => "admin"
    assert_response :success
  end

  test "should get show by user" do
    get :show, :id => users(:adminuser).id
    assert_response :success
  end

  test "should update user" do
    id = users(:adminuser).id
    put :update, :id => id, :roles => %w(admin hq mentor)
    assert_redirected_to "/roles/#{id}", flash[:notice]
    user = User.find(id)
    [:admin, :hq, :mentor].each do |r|
      assert user.has_role?(r), "User is missing #{r}"
    end
  end

end

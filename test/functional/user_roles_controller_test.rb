require 'test_helper'

class UserRolesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @user = users(:traineruser)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_roles)
  end

  test "should get index for user" do
    get :index, user_id: @user.id
    assert_response :success
    assert_not_nil assigns(:user_roles)
  end

  test "should create user_role" do
    assert_difference('UserRole.count') do
      post :create, user_id: @user.id, user_role: { :role => 'hq' }
    end

    assert_redirected_to user_user_roles_path(@user)
  end

  test "should destroy user_role" do
    assert_difference('UserRole.count', -1) do
      delete :destroy, user_id: user_roles(:hq1).user_id, id: user_roles(:hq1)
    end

    assert_redirected_to user_user_roles_path(user_roles(:hq1).user_id)
  end
end

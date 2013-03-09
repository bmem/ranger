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

  test "should create user_role" do
    assert_difference('UserRole.count') do
      post :create, user_role: { user_id: @user, :role => 'hq' }
    end

    assert_redirected_to user_role_path(assigns(:user).id)
  end

  test "should show user_role" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should destroy user_role" do
    assert_difference('UserRole.count', -1) do
      delete :destroy, id: user_roles(:hq1)
    end

    assert_redirected_to user_role_path(assigns(:user).id)
  end
end

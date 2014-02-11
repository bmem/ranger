require 'test_helper'

class TestingControllerTest < ActionController::TestCase
  setup do
    sign_in(users(:adminuser))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_equal users(:adminuser), assigns(:user)
  end

  test "should get mask_roles" do
    get :mask_roles
    assert_response :success
    assert_not_nil assigns(:roles)
    assert_not_nil assigns(:masked_roles)
    assert Role::ADMIN.in?(assigns(:roles))
  end

  test "should update mask_roles" do
    post :update_mask_roles, mask_roles: {admin: 1}
    assert_redirected_to testing_mask_roles_path
    assert_not_nil session[:masked_roles]
    assert session[:masked_roles].include?(:admin)
  end
end

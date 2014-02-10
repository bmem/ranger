require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get loggedin" do
    sign_in users(:adminuser)
    get :index
    assert_response :success
    assert_not_nil assigns(:person)
  end

  test "should get loggedout" do
    get :index
    assert_response :success
    assert_nil assigns(:person)
  end

end

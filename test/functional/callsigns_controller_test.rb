require 'test_helper'

class CallsignsControllerTest < ActionController::TestCase
  setup do
    sign_in(users(:adminuser))
    @callsign = callsigns(:hubcap)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:callsigns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create callsign" do
    assert_difference('Callsign.count') do
      post :create, callsign: { name: 'Brand New Callsign', note: 'For a test', status: 'pending' }
    end

    assert_redirected_to callsign_path(assigns(:callsign))
  end

  test "should show callsign" do
    get :show, id: @callsign
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @callsign
    assert_response :success
  end

  test "should update callsign" do
    put :update, id: @callsign, callsign: { name: @callsign.name, note: @callsign.note, status: @callsign.status }
    assert_redirected_to callsign_path(assigns(:callsign))
  end

  test "should destroy callsign" do
    assert_difference('Callsign.count', -1) do
      delete :destroy, id: @callsign
    end

    assert_redirected_to callsigns_path
  end
end

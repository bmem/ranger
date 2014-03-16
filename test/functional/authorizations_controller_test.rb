require 'test_helper'

class AuthorizationsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @authorization = authorizations(:one)
    @event = @authorization.event
  end

  test "should get index" do
    get :index, event_id: @event
    assert_response :success
    assert_not_nil assigns(:authorizations)
  end

  test "should get new" do
    get :new, event_id: @event
    assert_response :success
  end

  test "should create authorization" do
    assert_difference('Authorization.count') do
      post :create, event_id: @event, authorization: { type: @authorization.type, involvement_id: involvements(:e1p2).id }
    end

    assert_redirected_to event_authorization_path(@event, assigns(:authorization))
  end

  test "should show authorization" do
    get :show, event_id: @event, id: @authorization
    assert_response :success
  end

  test "should get edit" do
    get :edit, event_id: @event, id: @authorization
    assert_response :success
  end

  test "should update authorization" do
    put :update, event_id: @event, id: @authorization, authorization: { involvement_id: involvements(:e1p2).id }
    assert_redirected_to event_authorization_path(@event, assigns(:authorization))
  end

  test "should destroy authorization" do
    assert_difference('Authorization.count', -1) do
      delete :destroy, event_id: @event, id: @authorization
    end

    assert_redirected_to event_authorizations_path(@event)
  end
end

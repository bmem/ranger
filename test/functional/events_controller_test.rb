require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @event = events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      post :create, :event => { :name => 'Test Create', :type => 'GeneralEvent', :start_date => Date.yesterday, :end_date => Date.tomorrow }
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test "should show event" do
    get :show, :id => @event
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @event
    assert_response :success
  end

  test "should update event" do
    put :update, :id => @event, :event => { :name => @event.name, :description => 'New description', :type => @event.type, :start_date => @event.start_date, :end_date => @event.end_date }
    assert_redirected_to event_path(assigns(:event))
  end

  test "should destroy event" do
    assert_difference('Event.count', -1) do
      delete :destroy, :id => @event
    end

    assert_redirected_to events_path
  end
end

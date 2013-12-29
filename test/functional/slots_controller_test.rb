require 'test_helper'

class SlotsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @slot = slots(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:slots)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create slot" do
    assert_difference('Slot.count') do
      post :create, event_id: @slot.event.id, slot: {shift_id: @slot.shift_id, position_id: @slot.position_id, min_people: @slot.min_people, max_people: @slot.max_people}
    end

    assert_redirected_to slot_path(assigns(:slot))
  end

  test "should show slot" do
    get :show, :id => @slot
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @slot
    assert_response :success
  end

  test "should update slot" do
    put :update, id: @slot, slot: {min_people: 10, max_people: 20}
    assert_redirected_to slot_path(assigns(:slot))
  end

  test "should destroy slot" do
    assert_difference('Slot.count', -1) do
      delete :destroy, :id => @slot
    end

    assert_redirected_to slots_path
  end
end

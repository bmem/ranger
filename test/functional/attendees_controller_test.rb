require 'test_helper'

class AttendeesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @attendee = attendees(:one)
    @event = @attendee.event
  end

  test "should get index" do
    get :index, event_id: @event.id
    assert_response :success
    assert_not_nil assigns(:attendees)
  end

  test "should get new" do
    get :new, event_id: @event.id, slot_id: @attendee.slot_id, involvement_id: @attendee.involvement_id
    assert_response :success
  end

  test "should create attendee" do
    assert_difference('Attendee.count') do
      inv = involvements(:e1phq)
      post :create, event_id: @event.id, slot_id: @attendee.slot_id, involvement_id: inv.id, attendee: { status: 'confirmed' }
    end

    assert_redirected_to event_slot_attendee_path(@event, @attendee.slot_id, assigns(:attendee))
  end

  test "should show attendee" do
    get :show, id: @attendee, event_id: @event.id, slot_id: @attendee.slot_id
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @attendee, event_id: @event.id, slot_id: @attendee.slot_id
    assert_response :success
  end

  test "should update attendee" do
    put :update, id: @attendee, event_id: @event.id, slot_id: @attendee.slot_id, attendee: { status: 'noshow' }
    assert_redirected_to event_slot_attendee_path(@event, @attendee.slot_id, assigns(:attendee))
  end

  test "should destroy attendee" do
    assert_difference('Attendee.count', -1) do
      delete :destroy, id: @attendee, event_id: @event.id
    end

    assert_redirected_to event_slot_attendees_path(@event, @attendee.slot_id)
  end
end

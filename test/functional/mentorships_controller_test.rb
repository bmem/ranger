require 'test_helper'

class MentorshipsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @mentorship = mentorships(:one)
  end

  test "should get index" do
    get :index, event_id: @mentorship.event_id
    assert_response :success
    assert_not_nil assigns(:mentorships)
  end

  test "should get new" do
    get :new, event_id: @mentorship.event_id, mentee_id: @mentorship.mentee.id, shift_id: @mentorship.shift.id
    assert_response :success
  end

  test "should create mentorship" do
    assert_difference('Mentorship.count') do
      post :create, event_id: @mentorship.event_id, mentee_id: @mentorship.mentee.id, mentorship: { note: @mentorship.note, outcome: @mentorship.outcome, shift_id: @mentorship.shift_id }
    end

    assert_redirected_to event_mentorship_path(@mentorship.event, assigns(:mentorship))
  end

  test "should show mentorship" do
    get :show, event_id: @mentorship.event_id, id: @mentorship
    assert_response :success
  end

  test "should get edit" do
    get :edit, event_id: @mentorship.event_id, id: @mentorship
    assert_response :success
  end

  test "should update mentorship" do
    put :update, event_id: @mentorship.event_id, id: @mentorship, mentorship: { note: @mentorship.note, outcome: @mentorship.outcome }
    assert_redirected_to event_mentorship_path(@mentorship.event, assigns(:mentorship))
  end

  test "should destroy mentorship" do
    assert_difference('Mentorship.count', -1) do
      delete :destroy, event_id: @mentorship.event_id, id: @mentorship
    end

    assert_redirected_to event_mentorships_path(@mentorship.event)
  end
end

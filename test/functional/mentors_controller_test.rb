require 'test_helper'

class MentorsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @mentor = mentors(:one_one)
  end

  test "should get index" do
    get :index, event_id: @mentor.event_id
    assert_response :success
    assert_not_nil assigns(:mentors)
  end

  test "should get new" do
    get :new, event_id: @mentor.event_id
    assert_response :success
  end

  test "should create mentor" do
    assert_difference('Mentor.count') do
      post :create, event_id: @mentor.event_id, mentorship_id: @mentor.mentorship_id, mentor: { note: @mentor.note, vote: @mentor.vote, involvement_id: involvements(:bm2012_evangelist).id }
    end

    assert_redirected_to event_mentor_path(@mentor.event_id, assigns(:mentor))
  end

  test "should show mentor" do
    get :show, event_id: @mentor.event_id, id: @mentor
    assert_response :success
  end

  test "should get edit" do
    get :edit, event_id: @mentor.event_id, id: @mentor
    assert_response :success
  end

  test "should update mentor" do
    put :update, event_id: @mentor.event_id, id: @mentor, mentor: { note: @mentor.note, vote: @mentor.vote, involvement_id: @mentor.involvement.id }
    assert_redirected_to event_mentor_path(@mentor.event_id, assigns(:mentor))
  end

  test "should destroy mentor" do
    assert_difference('Mentor.count', -1) do
      delete :destroy, event_id: @mentor.event_id, id: @mentor
    end

    assert_redirected_to event_mentors_path(@mentor.event_id)
  end
end

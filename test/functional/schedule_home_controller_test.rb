require 'test_helper'

class ScheduleHomeControllerTest < ActionController::TestCase
  setup do
    sign_in users(:normaluser1)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_equal 1, assigns(:current_events).size
    assert_equal 1, assigns(:completed_events).size
    assert_equal 0, assigns(:upcoming_events).size
  end
end

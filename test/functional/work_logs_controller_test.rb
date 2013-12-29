require 'test_helper'

class WorkLogsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @work_log = work_logs(:one)
    @event = events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:work_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create work_log" do
    assert_difference('WorkLog.count') do
      post :create, event_id: @event.id, work_log: {position_id: positions(:dirt).id, involvement_id: @event.involvements.first.id, start_time: @event.start_date + 1.hour, end_time: @event.end_date - 1.hour}
    end

    assert_redirected_to work_log_path(assigns(:work_log))
  end

  test "should show work_log" do
    get :show, :id => @work_log
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @work_log
    assert_response :success
  end

  test "should update work_log" do
    put :update, id: @work_log, work_log: {start_time: @work_log.start_time - 1.hour, end_time: @work_log.end_time + 1.hour, position_id: @work_log.position_id, audit_comment: 'Test case'}
    assert_redirected_to work_log_path(assigns(:work_log))
  end

  test "should destroy work_log" do
    assert_difference('WorkLog.count', -1) do
      delete :destroy, :id => @work_log
    end

    assert_redirected_to event_work_logs_path(@work_log.event)
  end
end

require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @report = reports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reports)
  end

  test "should generate report" do
    assert_difference('Report.count') do
      post :generate, report_name: 'Birthday'
    end

    assert_redirected_to report_path(assigns(:report))
  end

  test "should show report" do
    get :show, id: @report
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @report
    assert_response :success
  end

  test "should update report" do
    put :update, id: @report, report: { name: 'Renamed Report', note: 'Check this out' }
    assert_redirected_to event_report_path(assigns(:event), assigns(:report))
  end

  test "should destroy report" do
    assert_difference('Report.count', -1) do
      delete :destroy, id: @report
    end

    assert_redirected_to event_reports_path(assigns(:event))
  end
end

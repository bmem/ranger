require 'test_helper'

class AuditsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    event = events(:one)
    event.description = 'Test description'
    event.audit_comment = 'Test audit comment'
    event.save!
    @audit = event.audits.last
  end

  test "should get index" do
    get :index
    assert_response :success
    assert assigns(:audits).count > 0
  end

  test "should get show" do
    get :show, id: @audit.id
    assert_response :success
    assert_equal @audit, assigns(:audit)
  end

end

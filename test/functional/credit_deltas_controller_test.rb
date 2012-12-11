require 'test_helper'

class CreditDeltasControllerTest < ActionController::TestCase
  setup do
    @credit_delta = credit_deltas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:credit_deltas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create credit_delta" do
    assert_difference('CreditDelta.count') do
      post :create, :credit_delta => { :end_time => @credit_delta.end_time, :hourly_rate => @credit_delta.hourly_rate, :name => @credit_delta.name, :start_time => @credit_delta.start_time }
    end

    assert_redirected_to credit_delta_path(assigns(:credit_delta))
  end

  test "should show credit_delta" do
    get :show, :id => @credit_delta
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @credit_delta
    assert_response :success
  end

  test "should update credit_delta" do
    put :update, :id => @credit_delta, :credit_delta => { :end_time => @credit_delta.end_time, :hourly_rate => @credit_delta.hourly_rate, :name => @credit_delta.name, :start_time => @credit_delta.start_time }
    assert_redirected_to credit_delta_path(assigns(:credit_delta))
  end

  test "should destroy credit_delta" do
    assert_difference('CreditDelta.count', -1) do
      delete :destroy, :id => @credit_delta
    end

    assert_redirected_to credit_deltas_path
  end
end

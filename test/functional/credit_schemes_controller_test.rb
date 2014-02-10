require 'test_helper'

class CreditSchemesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @credit_scheme = credit_schemes(:one)
  end

  test "should get index" do
    get :index, :event_id => @credit_scheme.event
    assert_response :success
    assert_not_nil assigns(:credit_schemes)
  end

  test "should get new" do
    get :new, :event_id => @credit_scheme.event
    assert_response :success
  end

  test "should create credit_scheme" do
    assert_difference('CreditScheme.count') do
      post :create, :event_id => @credit_scheme.event_id, :credit_scheme => { :base_hourly_rate => @credit_scheme.base_hourly_rate, :description => @credit_scheme.description, :name => @credit_scheme.name }
    end

    assert_redirected_to event_credit_scheme_path(assigns(:credit_scheme).event, assigns(:credit_scheme))
  end

  test "should show credit_scheme" do
    get :show, :id => @credit_scheme
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @credit_scheme
    assert_response :success
  end

  test "should update credit_scheme" do
    put :update, :id => @credit_scheme, :credit_scheme => { :base_hourly_rate => @credit_scheme.base_hourly_rate, :description => @credit_scheme.description, :name => @credit_scheme.name }
    assert_redirected_to event_credit_scheme_path(assigns(:credit_scheme).event, assigns(:credit_scheme))
  end

  test "should destroy credit_scheme" do
    assert_difference('CreditScheme.count', -1) do
      delete :destroy, :id => @credit_scheme
    end

    assert_redirected_to credit_schemes_path
  end
end
